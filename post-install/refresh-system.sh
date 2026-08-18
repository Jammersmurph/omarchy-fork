#!/bin/bash

set -euo pipefail

if (( EUID != 0 )); then
  echo "jammarchy-refresh-system must run as root" >&2
  exit 1
fi

ASSET_PATH=/usr/local/share/jammarchy

install -d -m 755 /etc/brave/policies/managed
install -m 644 "$ASSET_PATH/extensions.json" /etc/brave/policies/managed/extensions.json
[[ -e /etc/brave/policies/managed/color.json ]] || install -m 644 /dev/null /etc/brave/policies/managed/color.json

install -Dm644 "$ASSET_PATH/session.desktop" /usr/local/share/wayland-sessions/omarchy.desktop
install -Dm644 "$ASSET_PATH/sddm-metadata.desktop" /usr/share/sddm/themes/omarchy/metadata.desktop
install -Dm644 "$ASSET_PATH/omarchy.plymouth" /usr/share/plymouth/themes/omarchy/omarchy.plymouth
install -Dm644 "$ASSET_PATH/zz-jammarchy.conf" /etc/limine-entry-tool.d/zz-jammarchy.conf

if [[ -f /boot/limine.conf ]]; then
  perl -0pi -e 's/^interface_branding:.*$/interface_branding: Jammarchy Bootloader/m' /boot/limine.conf
fi

if command -v limine-update >/dev/null; then
  limine-update
fi
if command -v limine-snapper-sync >/dev/null; then
  limine-snapper-sync
fi
