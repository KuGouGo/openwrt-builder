# openwrt-builder

基于 **官方 OpenWrt 最新 release** 的 x86_64 固件构建仓库。

目标很简单：

- 跟随官方最新正式版
- 使用 ImageBuilder 快速出包
- 保持文件名与官方风格一致
- 仅发布最终需要的 EFI 镜像
- 使用中国境内镜像源加速软件包获取

## 当前构建目标

- Target: `x86/64`
- Profile: `generic`
- Filesystem: `squashfs`
- Final image: `combined-efi.img.gz`
- Timezone: `Asia/Shanghai`
- Rootfs partsize: `600`
- Kernel partsize: `32`
- Package mirror: `Tsinghua Tuna`

最终发布到 GitHub Release 的文件名格式为：

```txt
openwrt-25.12.0-x86-64-generic-squashfs-combined-efi.img.gz
```

实际版本号会随着官方最新 release 自动变化。

## 仓库结构

```txt
.github/workflows/build.yml   # GitHub Actions 构建与发布逻辑
cfg/pkgs.txt                  # 软件包列表（每行一个）
files/etc/config/system       # 时区、NTP、主机名等系统配置
files/etc/defaults/10-model   # x86 设备型号名修正
scripts/tune.sh               # 预留自定义调整脚本
```

## 工作流说明

工作流会自动执行以下步骤：

1. 获取官方 OpenWrt 最新 release tag
2. 下载对应版本的 x86_64 ImageBuilder
3. 生成国内 apk 软件源配置
4. 读取 `cfg/pkgs.txt` 作为软件包清单
5. 构建 x86_64 `generic` 的 `combined-efi.img.gz`
6. 仅保留最终 EFI 镜像
7. 上传到 GitHub Release

不会保留多余的：

- manifest
- buildinfo
- sha256sums
- json
- 其他镜像格式

## 软件包管理

软件包列表保存在：

```txt
cfg/pkgs.txt
```

规则：

- 每行一个包
- 支持空行
- 支持注释行（以 `#` 开头）
- 支持排除默认包，例如：

```txt
dnsmasq-full
-dnsmasq
```

当前包列表用于尽量贴近现有系统需求，同时保持构建逻辑简单稳定。

## 国内镜像源

默认使用清华 Tuna：

```txt
https://mirrors.tuna.tsinghua.edu.cn/openwrt
```

构建时会自动生成对应 release 的 apk 软件源配置到固件中。

如果以后要换源，只需要修改：

```txt
.github/workflows/build.yml
```

中的：

```txt
MIRROR_BASE
```

## 系统定制

### 时区

已预设：

- `Asia/Shanghai`
- `CST-8`

### NTP

默认使用国内常见时间服务器：

- `ntp.aliyun.com`
- `ntp1.aliyun.com`
- `ntp.tencent.com`

### 设备型号名修正

对于部分 x86 主板，如果 DMI 产品名显示为 `Default string`，会在首次启动时将型号展示修正为：

```txt
OpenWrt Router
```

对应文件：

```txt
files/etc/defaults/10-model
```

## 使用方式

### 手动构建

1. 打开仓库的 **Actions** 页面
2. 选择 `build`
3. 点击 **Run workflow**

### 构建结果

构建成功后，产物会发布到仓库的 **Releases** 页面。

只保留最终镜像：

```txt
openwrt-<version>-x86-64-generic-squashfs-combined-efi.img.gz
```

## 维护建议

日常维护通常只需要关注三个地方：

- `cfg/pkgs.txt`：增删软件包
- `files/etc/config/system`：修改系统配置
- `.github/workflows/build.yml`：修改构建与发布逻辑

## 说明

本仓库目标是：

- 尽量保持官方味道
- 尽量减少跨发行版魔改
- 尽量减少额外维护负担

如果后续新增功能，优先选择：

- 官方仓库已有包
- 简单 overlay
- 少量可维护的构建逻辑调整
