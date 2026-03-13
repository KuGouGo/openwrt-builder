#!/usr/bin/env bash
set -euo pipefail

# Fast OpenWrt firmware builder for GitHub Actions
# Features:
# - Set system timezone to Asia/Shanghai
# - Resize firmware/rootfs partition to 800MB
# - Add custom packages and feeds
# - Optional custom config hooks

REPO_URL="${REPO_URL:-https://github.com/coolsnowwolf/lede}"
REPO_BRANCH="${REPO_BRANCH:-master}"
WORKDIR="${WORKDIR:-$PWD/openwrt}"
TZ_NAME="${TZ_NAME:-Asia/Shanghai}"
ROOTFS_PARTSIZE="${ROOTFS_PARTSIZE:-800}"
KERNEL_PARTSIZE="${KERNEL_PARTSIZE:-64}"
JOBS="${JOBS:-$(sysctl -n hw.ncpu 2>/dev/null || nproc 2>/dev/null || echo 4)}"
CUSTOM_PACKAGES="${CUSTOM_PACKAGES:-luci i18n-base-zh-cn bash curl wget ca-bundle ca-certificates coreutils nano htop iperf3 tcping git git-http unzip luci-app-ttyd luci-app-upnp luci-app-ddns luci-app-filetransfer luci-app-argon-config luci-theme-argon}"
CUSTOM_FEEDS_GIT="${CUSTOM_FEEDS_GIT:-}"
TARGET_PROFILE="${TARGET_PROFILE:-}"

msg() {
  printf '\n==> %s\n' "$*"
}

ensure_repo() {
  if [ ! -d "$WORKDIR/.git" ]; then
    msg "Cloning source: $REPO_URL [$REPO_BRANCH]"
    git clone --depth 1 -b "$REPO_BRANCH" "$REPO_URL" "$WORKDIR"
  fi
}

patch_default_settings() {
  msg "Patching default settings"

  local zzz
  zzz="$(find "$WORKDIR/package" -type f -name 'zzz-default-settings' | head -n 1 || true)"
  if [ -n "$zzz" ]; then
    sed -i.bak "s#zonename='.*'#zonename='$TZ_NAME'#g" "$zzz" || true
    sed -i.bak "s#timezone='.*'#timezone='CST-8'#g" "$zzz" || true
  fi

  local config_generate
  config_generate="$(find "$WORKDIR/package" -type f -path '*/base-files/files/bin/config_generate' | head -n 1 || true)"
  if [ -n "$config_generate" ]; then
    perl -0pi -e "s#system\.@system\[-1\]\.timezone=.*#system.@system[-1].timezone='CST-8'#g" "$config_generate" || true
    perl -0pi -e "s#system\.@system\[-1\]\.zonename=.*#system.@system[-1].zonename='$TZ_NAME'#g" "$config_generate" || true
  fi
}

append_feeds() {
  if [ -n "$CUSTOM_FEEDS_GIT" ]; then
    msg "Adding custom feeds"
    printf '\n%s\n' "$CUSTOM_FEEDS_GIT" >> "$WORKDIR/feeds.conf.default"
  fi
}

prepare_feeds() {
  msg "Updating feeds"
  cd "$WORKDIR"
  ./scripts/feeds update -a
  ./scripts/feeds install -a
}

prepare_config() {
  msg "Generating base config"
  cd "$WORKDIR"

  cat > .config <<EOF
CONFIG_TARGET_IMAGES_GZIP=y
CONFIG_DEVEL=y
CONFIG_CCACHE=y
CONFIG_KERNEL_PARTSIZE=${KERNEL_PARTSIZE}
CONFIG_TARGET_ROOTFS_PARTSIZE=${ROOTFS_PARTSIZE}
EOF

  if [ -n "$TARGET_PROFILE" ]; then
    printf '%s\n' "$TARGET_PROFILE" >> .config
  fi

  for pkg in $CUSTOM_PACKAGES; do
    printf 'CONFIG_PACKAGE_%s=y\n' "$pkg" >> .config
  done

  if [ -f "$GITHUB_WORKSPACE/files/custom.config" ]; then
    msg "Merging custom.config"
    cat "$GITHUB_WORKSPACE/files/custom.config" >> .config
  fi

  make defconfig
}

run_custom_hooks() {
  cd "$WORKDIR"

  if [ -f "$GITHUB_WORKSPACE/files/diy-part1.sh" ]; then
    msg "Running diy-part1.sh"
    bash "$GITHUB_WORKSPACE/files/diy-part1.sh" "$WORKDIR"
  fi

  if [ -d "$GITHUB_WORKSPACE/files/files" ]; then
    msg "Copying custom files overlay"
    rsync -a "$GITHUB_WORKSPACE/files/files/" "$WORKDIR/files/"
  fi

  if [ -f "$GITHUB_WORKSPACE/files/diy-part2.sh" ]; then
    msg "Running diy-part2.sh"
    bash "$GITHUB_WORKSPACE/files/diy-part2.sh" "$WORKDIR"
  fi
}

download_sources() {
  msg "Downloading sources"
  cd "$WORKDIR"
  make download -j"$JOBS"
}

build_firmware() {
  msg "Building firmware with $JOBS jobs"
  cd "$WORKDIR"
  make -j"$JOBS" V=s
}

collect_artifacts() {
  msg "Collecting artifacts"
  cd "$WORKDIR"
  mkdir -p "$GITHUB_WORKSPACE/artifacts"
  find bin/targets -type f \( -name '*.bin' -o -name '*.img.gz' -o -name '*.itb' -o -name '*.tar' -o -name '*.manifest' -o -name '*.buildinfo' -o -name '*.json' -o -name '*.sha256sums' \) -exec cp -f {} "$GITHUB_WORKSPACE/artifacts/" \;
}

main() {
  ensure_repo
  append_feeds
  patch_default_settings
  prepare_feeds
  prepare_config
  run_custom_hooks
  download_sources
  build_firmware
  collect_artifacts
  msg "Done"
}

main "$@"
