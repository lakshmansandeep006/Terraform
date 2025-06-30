#!/bin/bash

set -e # Exit if any command fails 

echo "updating system..."
sudo dnf update -y

echo "installing required packages (unzip and curl)"
sudo dnf install unzip curl -y

echo "Downloading terraform_1.12.2"
curl -o terraform_1.12.2_linux_amd64.zip https://releases.hashicorp.com/terraform/1.12.2/terraform_1.12.2_linux_amd64.zip

echo "Extracting terraform_1.12.2"
sudo unzip terraform_1.12.2_linux_amd64.zip .

echo "moving terraform to /usr/local/bin/"
sudo mv terraform /usr/local/bin/

echo "setting executable permissions"
sudo chmod +x terraform LICENSE.txt

echo "cleaning up.."
rm -rf terraform_1.12.2_linux_amd64.zip

echo "terraform installed successfully"
terraform version