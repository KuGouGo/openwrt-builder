#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
NIKKI_DIR="$ROOT/files/tmp/nikki-feed"
mkdir -p "$NIKKI_DIR"

VER="${1:?openwrt version required}"
REL_JSON="$(curl --retry 3 --retry-all-errors --connect-timeout 15 --max-time 60 -fsSL https://api.github.com/repos/nikkinikki-org/OpenWrt-nikki/releases/latest)"
TAG="$(printf '%s' "$REL_JSON" | jq -r '.tag_name')"
ASSET="nikki_x86_64-openwrt-${VER%.*}.tar.gz"
URL="$(printf '%s' "$REL_JSON" | jq -r --arg name "$ASSET" '.assets[] | select(.name==$name) | .browser_download_url' | head -n 1)"

if [ -z "$URL" ] || [ "$URL" = "null" ]; then
  echo "nikki release asset not found: $ASSET" >&2
  exit 1
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

curl --retry 3 --retry-all-errors --connect-timeout 20 --max-time 180 -fL "$URL" -o "$TMP/nikki.tar.gz"
rm -rf "$NIKKI_DIR"/*
tar -xzf "$TMP/nikki.tar.gz" -C "$NIKKI_DIR"


echo "Fetched Nikki release: $TAG"
echo "Asset: $ASSET"
