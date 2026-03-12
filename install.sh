#!/bin/bash

set -e

REPO="usememos/memos"
BINARY_NAME="memos"
INSTALL_DIR="$HOME/.local/bin"

if [[ "$(uname -s)" == *"MINGW"* || "$(uname -s)" == *"MSYS"* || "$(uname -s)" == "Windows_NT" ]]; then
    BINARY_NAME="memos.exe"
fi

echo "Checking for latest version..."

LATEST_TAG=$(curl -sL "https://api.github.com/repos/$REPO/releases/latest" | grep -oP '"tag_name":\s*"\K[^"]+')
VERSION="${LATEST_TAG#v}"

echo "Latest version: $LATEST_TAG"

# Skip version check since memos doesn't have --version flag

OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"

case "$OS" in
    linux*)
        case "$ARCH" in
            x86_64) ASSET_NAME="memos_${VERSION}_linux_amd64.tar.gz" ;;
            aarch64) ASSET_NAME="memos_${VERSION}_linux_arm64.tar.gz" ;;
            armv7) ASSET_NAME="memos_${VERSION}_linux_armv7.tar.gz" ;;
            *)
                echo "Unsupported architecture: $ARCH"
                exit 1
                ;;
        esac
        ;;
    darwin*)
        case "$ARCH" in
            x86_64) ASSET_NAME="memos_${VERSION}_darwin_amd64.tar.gz" ;;
            arm64) ASSET_NAME="memos_${VERSION}_darwin_arm64.tar.gz" ;;
            *)
                echo "Unsupported architecture: $ARCH"
                exit 1
                ;;
        esac
        ;;
    mingw*|msys*|windows*)
        case "$ARCH" in
            x86_64) ASSET_NAME="memos_${VERSION}_windows_amd64.zip" ;;
            *)
                echo "Unsupported architecture: $ARCH"
                exit 1
                ;;
        esac
        ;;
    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

DOWNLOAD_URL="https://github.com/$REPO/releases/download/$LATEST_TAG/$ASSET_NAME"

echo "Downloading from: $DOWNLOAD_URL"

mkdir -p "$INSTALL_DIR"

if [[ "$ASSET_NAME" == *.zip ]]; then
    echo "Downloading..."
    curl -fL "$DOWNLOAD_URL" -o "/tmp/memos_install.zip"
    echo "Extracting..."
    unzip -q -o "/tmp/memos_install.zip" -d "$INSTALL_DIR"
    rm -f "/tmp/memos_install.zip"
else
    echo "Downloading..."
    curl -fL "$DOWNLOAD_URL" -o "/tmp/memos_install.tar.gz"
    echo "Extracting..."
    tar -xzf "/tmp/memos_install.tar.gz" -C "$INSTALL_DIR" memos
    chmod +x "$INSTALL_DIR/$BINARY_NAME"
    rm -f "/tmp/memos_install.tar.gz"
fi

echo "Installed to $INSTALL_DIR/$BINARY_NAME"
echo ""
echo "Run: $BINARY_NAME --version"
