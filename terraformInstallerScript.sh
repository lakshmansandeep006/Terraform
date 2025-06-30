#!/bin/bash

set -euo pipefail

# ----------------------------
# CONFIGURATION
# ----------------------------
readonly TERRAFORM_VERSION="1.8.4"
readonly INSTALL_DIR="/usr/local/bin"
readonly TEMP_DIR="/tmp/terraform-install-$$"
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
    sudo chmod 750 "$LOG_DIR"
    sudo chown root:root "$LOG_DIR"
fi

# Open log file for all stdout and stderr from commands
exec 3>&1 4>&2                    # Save current stdout/stderr
exec > >(tee -a "$LOGFILE" >&4)  # Redirect stdout to log + original stderr
exec 2>&1                        # Redirect stderr to stdout (so both go to log)

# ----------------------------
# LOGGING FUNCTION: print only echo to terminal
# ----------------------------
log_echo() {
    # Timestamped echo to both console and log
    local ts
    ts=$(date '+%Y-%m-%d %H:%M:%S')
    # Print to console only (fd 3 is original stdout)
    echo -e "[$ts] $*" >&3
    # Also print to logfile (fd 1 now logs everything)
    echo -e "[$ts] $*"
}

log_echo "=== Terraform Installer started at $(date) ==="

# ----------------------------
# FUNCTION: Check Existing Installation
# ----------------------------
is_terraform_installed() {
    if command -v terraform >/dev/null 2>&1; then
        local installed_version
        installed_version=$(terraform version | head -n1 | awk '{print $2}' | sed 's/^v//')
        if [[ "$installed_version" == "$TERRAFORM_VERSION" ]]; then
            log_echo "✅ Terraform v$TERRAFORM_VERSION is already installed at: $(which terraform)"
            return 0
        else
            log_echo "⚠️ Installed Terraform version is $installed_version, expected $TERRAFORM_VERSION. Will update."
            return 1
        fi
    else
        log_echo "❌ Terraform not found. Proceeding with installation."
        return 1
    fi
}

# ----------------------------
# MAIN SCRIPT
# ----------------------------

if is_terraform_installed; then
    log_echo "No action needed. Exiting."
    exit 0
fi

log_echo "▶ Updating package cache..."
sudo dnf -y update >/dev/null 2>&1

log_echo "▶ Installing dependencies (curl, unzip)..."
sudo dnf install -y curl unzip >/dev/null 2>&1

log_echo "▶ Creating secure temporary workspace at $TEMP_DIR..."
mkdir -p "$TEMP_DIR"
chmod 700 "$TEMP_DIR"
cd "$TEMP_DIR"

log_echo "▶ Downloading Terraform v$TERRAFORM_VERSION..."
curl -fsSL -o terraform.zip "$DOWNLOAD_URL" >/dev/null 2>&1

log_echo "▶ Extracting Terraform binary..."
unzip -o terraform.zip >/dev/null 2>&1

log_echo "▶ Installing Terraform binary to $INSTALL_DIR..."
sudo mv -f terraform "$TERRAFORM_BIN"
sudo chmod 755 "$TERRAFORM_BIN"

log_echo "▶ Cleaning up temporary files..."
cd /
rm -rf "$TEMP_DIR"

log_echo "✅ Terraform v$TERRAFORM_VERSION installed successfully."
terraform version

log_echo "=== Installer finished at $(date) ==="
log_echo "▶ Full install logs saved at $LOGFILE"

exit 0
