#!/bin/bash

set -euo pipefail

# -----------------------------
# CONFIGURATION
# -----------------------------
TERRAFORM_VERSION="1.8.4"
INSTALL_DIR="/usr/local/bin"
TEMP_DIR="/tmp/terraform-install"
TERRAFORM_BIN="${INSTALL_DIR}/terraform"
DOWNLOAD_URL="https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"

# -----------------------------
# FUNCTION: Check Existing Installation
# -----------------------------
is_terraform_installed() {
    if command -v terraform >/dev/null 2>&1; then
        local installed_version
        installed_version=$(terraform version | head -n 1 | awk '{print $2}' | sed 's/^v//')
        if [[ "$installed_version" == "$TERRAFORM_VERSION" ]]; then
            echo "Terraform v$TERRAFORM_VERSION is already installed at: $(which terraform)"
            return 0
        else
            echo "Installed Terraform version is $installed_version, expected $TERRAFORM_VERSION. Proceeding with update..."
            return 1
        fi
    else
        echo "Terraform not found. Proceeding with fresh installation..."
        return 1
    fi
}

# -----------------------------
# MAIN EXECUTION
# -----------------------------
if is_terraform_installed; then
    exit 0
fi

echo "▶ Updating package index..."
sudo dnf -y update

echo "▶ Installing dependencies: curl, unzip"
sudo dnf install -y curl unzip

echo "▶ Creating temporary install directory..."
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"

echo "▶ Downloading Terraform v$TERRAFORM_VERSION..."
curl -fsSL -o terraform.zip "$DOWNLOAD_URL"

echo "▶ Extracting Terraform..."
unzip -o terraform.zip

echo "▶ Installing Terraform to $INSTALL_DIR..."
sudo mv -f terraform "$TERRAFORM_BIN"
sudo chmod +x "$TERRAFORM_BIN"

echo
