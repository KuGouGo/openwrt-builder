# openwrt-builder

> Build a clean, release-based OpenWrt x86_64 image with a small set of practical customizations.

一个面向日常使用的 **官方 OpenWrt x86_64 自动构建仓库**。  
目标不是做一套大而全的魔改系统，而是基于**官方正式发行版**，稳定地产出一个顺手、干净、命名规范的镜像。

---

## Overview

这套仓库的设计思路很简单：

- **只跟官方发行版**，不跟 snapshot
- **只做 x86_64 / generic**，不把目标搞太散
- **只保留最终镜像**，不堆无关产物
- **只做少量定制**，降低维护成本
- **只手动触发构建**，避免无意义消耗 Actions 配额

如果你想要的是：

- 尽量保留官方风格
- 带上自己常用的软件包
- 默认时区和源更适合国内环境
- 构建结果能直接放到 Release 页面下载

那么这个仓库就是为这种场景准备的。

---

## Features

- 基于 **官方 OpenWrt 最新 release** 自动构建
- 使用 **官方 ImageBuilder**，构建更快、更轻量
- 固件产物统一发布到 **GitHub Releases**
- 默认使用 **清华 Tuna** 镜像源
- 默认时区为 **Asia/Shanghai**
- 固件命名风格尽量贴近官方
- 仅保留最终目标镜像，不上传杂项文件

---

## Output

构建完成后，Release 中只保留一个最终镜像：

```txt
openwrt-<version>-x86-64-generic-squashfs-combined-efi.img.gz
```

例如：

```txt
openwrt-25.12.0-x86-64-generic-squashfs-combined-efi.img.gz
```

这也是整个仓库唯一真正关注的产物。

---

## Build Target

当前默认构建目标如下：

- **Target:** `x86/64`
- **Profile:** `generic`
- **Filesystem:** `squashfs`
- **Image type:** `combined-efi.img.gz`
- **Rootfs partsize:** `600`
- **Kernel partsize:** `32`
- **Timezone:** `Asia/Shanghai`
- **Trigger mode:** `workflow_dispatch`

---

## Repository Layout

```txt
.github/workflows/build.yml   GitHub Actions 构建与发布逻辑
cfg/pkgs.txt                  软件包列表
files/etc/config/system       系统基础配置（时区 / NTP / 主机名）
files/etc/defaults/10-model   x86 型号名修正脚本
scripts/tune.sh               自定义调整入口
```

### 最常修改的文件

日常维护时，通常只需要关心下面三个：

- `cfg/pkgs.txt`
- `files/etc/config/system`
- `.github/workflows/build.yml`

---

## How It Works

构建流程大致如下：

1. 获取 `openwrt/openwrt` 最新正式 release
2. 下载对应版本的官方 x86_64 ImageBuilder
3. 写入国内可用的软件源配置
4. 读取 `cfg/pkgs.txt` 中的软件包清单
5. 构建 `x86_64 / generic / squashfs / combined-efi` 镜像
6. 仅提取最终目标镜像
7. 发布到当前仓库的 **GitHub Releases**

整个流程偏向“**官方发行版再打包**”，而不是“完整源码编译自定义发行版”。

这也是它更适合长期维护的原因之一。

---

## Package List

软件包清单保存在：

```txt
cfg/pkgs.txt
```

格式约定：

- 一行一个包
- 支持空行
- 支持注释
- 支持移除默认包

示例：

```txt
dnsmasq-full
-dnsmasq
```

表示：

- 添加 `dnsmasq-full`
- 移除默认 `dnsmasq`

这种写法适合保持包列表清晰，也方便长期维护。

---

## System Defaults

系统默认配置位于：

```txt
files/etc/config/system
```

当前包含：

- `Asia/Shanghai` 时区
- `CST-8` 时区配置
- 国内常用 NTP 服务器

默认 NTP 源包括：

- `ntp.aliyun.com`
- `ntp1.aliyun.com`
- `ntp.tencent.com`

---

## China Mirror

默认软件源镜像：

```txt
https://mirrors.tuna.tsinghua.edu.cn/openwrt
```

构建时会根据当前官方 release 自动生成对应的 apk 源配置。  
如果以后需要切换到其他镜像，只需要修改 workflow 中的：

```txt
MIRROR_BASE
```

---

## x86 Model Name Fix

一些 x86 设备在 LuCI 中会把型号显示成：

```txt
Default string
```

为了让页面看起来更正常，仓库里加了一个很小的修正：

- 如果检测到设备型号是 `Default string`
- 就把展示名改成 `OpenWrt Router`

对应文件：

```txt
files/etc/defaults/10-model
```

这个改动不大，但对观感很有用。

---

## Triggering a Build

当前工作流是 **手动触发** 的。

使用方式：

1. 打开仓库的 **Actions** 页面
2. 选择工作流：`build`
3. 点击 **Run workflow**

不会自动执行以下行为：

- 不会因为 push 自动构建
- 不会定时跑
- 不会在你提交配置时偷偷开始编译

这能让构建行为保持可控，也更节省 GitHub Actions 资源。

---

## Release Behavior

构建成功后：

- 产物会发布到 **Releases** 页面
- 只保留最终镜像文件
- 命名尽量贴近官方风格

默认不会额外保留这些文件：

- `manifest`
- `buildinfo`
- `sha256sums`
- `json`
- 其他不需要的镜像格式

如果目标很明确，这种发布方式会更干净。

---

## Why ImageBuilder

这个仓库选择 ImageBuilder，而不是完整源码编译，主要是因为目标非常明确：

- 使用官方发行版
- 增删少量软件包
- 做一点基础配置
- 快速出镜像

对于这种需求，ImageBuilder 通常有更好的平衡：

- 更快
- 更简单
- 更稳定
- 更容易维护

如果以后要做的是：

- 深度补丁
- 跨发行版移植包
- 修改 target 逻辑
- 大量底层裁剪

那再切到完整源码编译会更合适。

---

## Maintenance Notes

为了保持仓库长期可用，建议遵循一个简单原则：

> 能用官方方案解决的，就尽量别走复杂路线。

### 推荐做法

- 调整 `cfg/pkgs.txt`
- 修改 overlay 配置
- 做少量、明确的构建逻辑改动

### 不推荐轻易做的事

- 跨发行版搬包
- 引入大量第三方补丁
- 把仓库扩展成重型定制系统

这个仓库最有价值的地方，不是功能堆得多，而是它一直能稳定地生成你真正想要的那个镜像。

---

## Quick Start

如果你只是想快速用起来：

1. 修改 `cfg/pkgs.txt`
2. 按需调整 `files/etc/config/system`
3. 进入 **Actions** 手动运行 `build`
4. 去 **Releases** 下载最终镜像

就这么简单。

---

## License / Upstream

本仓库基于：

- 官方 OpenWrt release
- 官方 OpenWrt ImageBuilder

如果你在这个仓库基础上继续扩展，建议尽量保持对上游结构和命名风格的尊重，这样后续维护会轻松很多。