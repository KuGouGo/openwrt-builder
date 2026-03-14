# OpenWrt Builder

[![Build](https://img.shields.io/github/actions/workflow/status/KuGouGo/OpenWrt-Builder/build.yml?branch=main&label=build)](https://github.com/KuGouGo/OpenWrt-Builder/actions/workflows/build.yml)
[![Release](https://img.shields.io/github/v/release/KuGouGo/OpenWrt-Builder?display_name=tag&label=release)](https://github.com/KuGouGo/OpenWrt-Builder/releases)
[![Upstream](https://img.shields.io/badge/upstream-OpenWrt-00b5e2)](https://github.com/openwrt/openwrt)
[![Target](https://img.shields.io/badge/target-x86%2F64-generic)](https://openwrt.org/)

Build official OpenWrt x86_64 release images with a small, release-based workflow.

## Layout

```txt
.github/workflows/build.yml
config/build.conf
config/packages.list
files/
README.md
```

- `config/build.conf`: static build target config
- `config/packages.list`: package list
- `files/`: files copied into the final image
- `.github/workflows/build.yml`: build and release pipeline

## Build flow

1. Fetch latest official OpenWrt release
2. Load build settings from `config/build.conf`
3. Download matching official ImageBuilder
4. Copy `files/` into ImageBuilder
5. Parse `config/packages.list`
6. Build image
7. Upload diagnostics and release assets

## Trigger

Run `Actions -> build -> Run workflow`.

This workflow has no manual inputs. Build behavior comes from `config/build.conf` and `config/packages.list`.

## Build config

```conf
OPENWRT_TARGET=x86
OPENWRT_SUBTARGET=64
OPENWRT_PROFILE=generic
OPENWRT_FS=squashfs
OPENWRT_IMAGE=combined-efi.img.gz
ROOTFS_PARTSIZE=600
BUILD_BASE=https://downloads.openwrt.org
PACKAGES_FILE=config/packages.list
```

## Notes

- Targets new ImageBuilder layout (`repositories`)
- Uses official OpenWrt release ImageBuilder, not full source compilation
- Keeps diagnostics even on build failure
- Prefers exact image filename, then safe fallback match

## Download

<https://github.com/KuGouGo/OpenWrt-Builder/releases>
