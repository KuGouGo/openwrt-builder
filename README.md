# openwrt-builder

[![Build](https://img.shields.io/github/actions/workflow/status/KuGouGo/openwrt-builder/build.yml?branch=main&label=build)](https://github.com/KuGouGo/openwrt-builder/actions/workflows/build.yml)
[![Release](https://img.shields.io/github/v/release/KuGouGo/openwrt-builder?display_name=tag&label=release)](https://github.com/KuGouGo/openwrt-builder/releases)
[![Upstream](https://img.shields.io/badge/upstream-OpenWrt-00b5e2)](https://github.com/openwrt/openwrt)
[![Target](https://img.shields.io/badge/target-x86%2F64-generic)](https://openwrt.org/)

Build official OpenWrt x86_64 release images with a small set of practical customizations.

## Output

```txt
openwrt-<version>-x86-64-generic-squashfs-combined-efi.img.gz
```

Current defaults:

- official latest release
- x86/64 generic
- squashfs combined-efi
- Asia/Shanghai
- rootfs 600 / kernel 32
- China mirror (Tuna)
- manual run only

## Usage

1. Edit package list: `cfg/pkgs.txt`
2. Edit system config: `files/etc/config/system`
3. Run workflow: `Actions -> build -> Run workflow`
4. Download image from `Releases`

## Files

```txt
.github/workflows/build.yml
cfg/pkgs.txt
files/etc/config/system
files/etc/defaults/10-model
scripts/tune.sh
```

## Download

Releases:

<https://github.com/KuGouGo/openwrt-builder/releases>

Expected file:

```txt
openwrt-<version>-x86-64-generic-squashfs-combined-efi.img.gz
```
