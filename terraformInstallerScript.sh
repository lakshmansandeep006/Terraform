#!/bin/bash

set -euo pipefail

# ----------------------------
# CONFIGURATION
# ----------------------------
readonly TERRAFORM_VERSION="1.8.4"
readonly INSTALL_DIR="/usr/local/bin"
readonly TEMP_DIR="/tmp/terraform-install-$$"   # unique temp dir per run
readonly LOG_DIR="/var/log/terraform_install"
readonly LOGFILE="${LOG_DIR}/install_terraform_$(date +'%Y%m%d_%H%M%S').log"
readonly TERRAFORM_BIN="${INSTALL_DIR}/terraform"
readonly DOWNLOAD_URL="https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"

# ----------------------------
# PREPARE LOGGING
# ----------------------------

# Create secure log directory if missing
if [[ ! -d "$LOG_DIR" ]]; then
    sudo mkdir -p "$LOG_DIR"
    sudo chmod 750 "$LOG_DIR"          # only root + group can read/exec
    sudo chown root:root "$LOG_DIR"    # owned by root
fi

# Redirect all stdout and stderr to logfile, but keep echo outputs on console.
exec > >(tee -a "$LOGFILE") 2>&1

echo "=== Terraform Installer started at $(date) ==="

# ----------------------------
# FUNCTION: Check Existing Installation
# ----------------------------
is_terraform_installed() {
    if command -v terraform >/dev/null 2>&1; then
        local installed_version
        installed_version=$(terraform version | head -n1 | awk '{print $2}' | sed 's/^v//')
        if [[ "$installed_version" == "$TERRAFORM_VERSION" ]]; then
            echo "✅ Terraform v$TERRAFORM_VERSION is already installed at: $(which terraform)"
            return 0
        else
            echo "⚠️ Installed Terraform version is $installed_version, expected $TERRAFORM_VERSION. Will update."
            return 1
        fi
    else
        echo "❌ Terraform not found. Proceeding with installation."
        return 1
    fi
}

# ----------------------------
# MAIN SCRIPT
# ----------------------------

if is_terraform_installed; then
    echo "No action needed. Exiting."
    exit 0
fi

echo "▶ Updating package cache..."
sudo dnf -y update

echo "▶ Installing dependencies (curl, unzip)..."
sudo dnf install -y curl unzip

echo "▶ Creating secure temporary workspace at $TEMP_DIR..."
mkdir -p "$TEMP_DIR"
chmod 700 "$TEMP_DIR"
cd "$TEMP_DIR"

echo "▶ Downloading Terraform v$TERRAFORM_VERSION..."
curl -fsSL -o terraform.zip "$DOWNLOAD_URL"

echo "▶ Extracting Terraform binary..."
unzip -o terraform.zip

echo "▶ Installing Terraform binary to $INSTALL_DIR..."
sudo mv -f terraform "$TERRAFORM_BIN"
sudo chmod 755 "$TERRAFORM_BIN"    # executable by all users but only writable by root

echo "▶ Cleaning up temporary files..."
cd /
rm -rf "$TEMP_DIR"

echo "✅ Terraform v$TERRAFORM_VERSION installed successfully."
terraform version

echo "=== Installer finished at $(date) ==="
echo "▶ Full installation logs saved at $LOGFILE"

exit 0
