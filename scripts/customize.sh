#!/usr/bin/env bash
set -euo pipefail

IMAGEBUILDER_DIR="${1:-imagebuilder}"
RELEASE_VERSION="${2:-unknown}"

echo "Custom hook running for OpenWrt ${RELEASE_VERSION} in ${IMAGEBUILDER_DIR}"

# 这里可以按需加自定义逻辑，例如：
# - 替换默认 IP
# - 写入自定义 banner
# - 复制额外配置
# - 调整默认主题
