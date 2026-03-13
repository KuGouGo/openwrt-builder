# OpenWrt GitHub Actions 构建模板

已生成内容：

- `.github/workflows/build-openwrt.yml`
- `files/etc/config/system`
- `files/etc/apk/repositories.d/.gitkeep`
- `scripts/customize.sh`

## 功能

- 官方 OpenWrt 最新 release
- x86_64 / generic
- 默认中国镜像源（清华 Tuna）
- 时区：Asia/Shanghai
- ROOTFS_PARTSIZE=800
- KERNEL_PARTSIZE=64
- 保留 sing-box
- 使用 ImageBuilder 快速构建

## 使用

1. 把这些文件推到你的 GitHub 仓库
2. 进入 Actions
3. 手动运行 `Build OpenWrt x86_64 (Official Latest Release)`
4. 在 Artifacts 下载固件

## 当前包列表

```txt
bash ca-bundle curl dnsmasq-full -dnsmasq dropbear e2fsprogs ethtool htop ip-full jq lsblk nano odhcp6c odhcpd-ipv6only openssh-sftp-server pciutils ppp ppp-mod-pppoe sing-box usbutils wget-ssl luci luci-app-firewall luci-app-package-manager luci-i18n-base-zh-cn luci-i18n-firewall-zh-cn luci-i18n-package-manager-zh-cn luci-theme-bootstrap
```

## 说明

- `distfeeds.list` 会在 GitHub Actions 运行时按最新 release 版本自动生成
- 如果后续要换 USTC 或其他镜像，只需要改 workflow 里的 `MIRROR_BASE`
- 如果要增删软件包，改 workflow 里的 `PACKAGES`
