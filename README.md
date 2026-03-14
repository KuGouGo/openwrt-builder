# OpenWrt Builder

[![Build](https://img.shields.io/github/actions/workflow/status/KuGouGo/OpenWrt-Builder/build.yml?branch=main&label=build)](https://github.com/KuGouGo/OpenWrt-Builder/actions/workflows/build.yml)
[![Release](https://img.shields.io/github/v/release/KuGouGo/OpenWrt-Builder?display_name=tag&label=release)](https://github.com/KuGouGo/OpenWrt-Builder/releases)
[![Upstream](https://img.shields.io/badge/upstream-OpenWrt-00b5e2)](https://github.com/openwrt/openwrt)
[![Target](https://img.shields.io/badge/target-x86%2F64-generic)](https://openwrt.org/)

Build official OpenWrt x86_64 release images with a clean, release-based workflow. Supports Nikki feed integration for official release builds.

The workflow is intentionally optimized for x86_64 only. It follows the official Image Builder usage: custom packages are copied into `imagebuilder/packages/`, then Image Builder generates the local package index itself during `make image`. Nikki packages are fetched from the upstream Nikki feed (`nikkinikki.pages.dev`) based on the matching OpenWrt branch.

## Usage

1. Edit package list: `cfg/pkgs.txt`
2. Edit system config: `files/etc/config/system`
3. Run workflow: `Actions -> build -> Run workflow`
4. The workflow first runs `make manifest` as a dependency preflight
5. Download image from `Releases`

## Files

```txt
.github/workflows/build.yml
cfg/pkgs.txt
files/etc/config/system
files/etc/defaults/10-model
scripts/tune.sh
```

## Download

<https://github.com/KuGouGo/OpenWrt-Builder/releases>
