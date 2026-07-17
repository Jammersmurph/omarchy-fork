#!/bin/bash

set -eEo pipefail

ansi_art='   ___  ___  ___  ______  ___  ___  ______  _____  _   ___   __
  |_  |/ _ \ |  \/  ||  \/  | / _ \ | ___ \/  __ \| | | \ \ / /
    | / /_\ \| .  . || .  . |/ /_\ \| |_/ /| /  \/| |_| |\ V / 
    | |  _  || |\/| || |\/| ||  _  ||    / | |    |  _  | \ /  
/\__/ / | | || |  | || |  | || | | || |\ \ | \__/\| | | | | |  
\____/\_| |_/\_|  |_/\_|  |_/\_| |_/\_| \_| \____/\_| |_/ \_/  '

clear
echo -e "\n$ansi_art\n"

export OMARCHY_ONLINE_INSTALL=true
export OMARCHY_MIRROR=stable
echo 'Server = https://stable-mirror.omarchy.org/$repo/os/$arch' | sudo tee /etc/pacman.d/mirrorlist >/dev/null

sudo pacman -Syu --noconfirm --needed git

echo -e "\nCloning Jammarchy fork..."
rm -rf ~/.local/share/omarchy/
git clone https://github.com/Jammersmurph/omarchy-fork.git ~/.local/share/omarchy >/dev/null

echo -e "\nInstallation starting..."
bash ~/.local/share/omarchy/install.sh
