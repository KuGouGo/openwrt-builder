#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
NIKKI_DIR="$ROOT/files/tmp/nikki-feed"
mkdir -p "$NIKKI_DIR"

VER="${1:?openwrt version required}"
ARCH="${2:-x86_64}"

case "$VER" in
  24.10*) BRANCH="openwrt-24.10" ;;
  25.12*) BRANCH="openwrt-25.12" ;;
  *)
    echo "unsupported Nikki branch for OpenWrt version: $VER" >&2
    exit 1
    ;;
esac

REPOSITORY_URL="https://nikkinikki.pages.dev"
FEED_URL="$REPOSITORY_URL/$BRANCH/$ARCH/nikki"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

rm -rf "$NIKKI_DIR"/*

fetch() {
  local url="$1"
  local out="$2"
  curl --retry 3 --retry-all-errors --connect-timeout 20 --max-time 180 -fL "$url" -o "$out"
}

echo "Fetching Nikki feed from: $FEED_URL"

if fetch "$FEED_URL/packages.adb" "$TMP/packages.adb"; then
  cp -f "$TMP/packages.adb" "$NIKKI_DIR/packages.adb"
else
  echo "failed to fetch Nikki packages.adb from $FEED_URL" >&2
  exit 1
fi

index_html="$(curl --retry 3 --retry-all-errors --connect-timeout 20 --max-time 180 -fsSL "$FEED_URL/")"

for pkg in nikki luci-app-nikki luci-i18n-nikki-zh-cn; do
  match="$(printf '%s' "$index_html" \
    | grep -oE ">${pkg}-[^<]+\\.apk<" \
    | sed -e 's/^>//' -e 's/<$//' \
    | sort -u \
    | tail -n 1 || true)"

  if [ -z "$match" ]; then
    echo "package not found in Nikki feed: $pkg" >&2
    exit 1
  fi

  fetch "$FEED_URL/$match" "$NIKKI_DIR/$match"
done

echo "Fetched Nikki feed branch: $BRANCH"
echo "Fetched Nikki arch       : $ARCH"
find "$NIKKI_DIR" -maxdepth 1 -type f | sort
