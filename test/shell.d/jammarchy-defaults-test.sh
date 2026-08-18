#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

grep -q "brave-bin" "$ROOT/setup.sh" || fail "setup installs Brave"
grep -q "pacman -S --needed --noconfirm alacritty" "$ROOT/setup.sh" || fail "setup installs Alacritty"
grep -q "brave-browser.desktop" "$ROOT/default/applications/mimeapps.list" || fail "Brave is the seeded browser"
grep -q "brave-browser.desktop" "$ROOT/bin/omarchy-provision-user" || fail "Brave is the finalized browser"
grep -q "CRAG666/code_runner.nvim" "$ROOT/default/nvim/code-runner.lua" || fail "Code Runner is provisioned"
grep -q 'omarchy-theme-set "Aetheria"' "$ROOT/install/user/theme.sh" || fail "Aetheria is the default theme"
grep -q "rounding = 10" "$ROOT/config/hypr/looknfeel.lua" || fail "rounded corners are preserved"

pass "Jammarchy defaults are configured"
