#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
test_home="$test_tmp/home"
system_path="$test_tmp/omarchy"
sudo_log="$test_tmp/sudo.log"
command_log="$test_tmp/commands.log"
mkdir -p "$mock_bin" "$test_home" "$system_path"

cat >"$mock_bin/sudo" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$JAMMARCHY_TEST_SUDO_LOG"
if [[ $* == "-n -v" && ${JAMMARCHY_TEST_REFRESH_SUDO:-1} == "0" ]]; then
  exit 1
fi
if [[ ${1:-} == "-n" ]]; then
  shift
fi
[[ ${1:-} == "test" ]] && exit 1
exit 0
SH

cat >"$mock_bin/pacman" <<'SH'
#!/bin/bash
printf 'pacman %s\n' "$*" >>"$JAMMARCHY_TEST_COMMAND_LOG"
[[ ${1:-} != "-Q" ]]
SH

cat >"$mock_bin/yay" <<'SH'
#!/bin/bash
printf 'yay %s\n' "$*" >>"$JAMMARCHY_TEST_COMMAND_LOG"
SH

for command in omarchy omarchy-refresh-applications omarchy-default-browser omarchy-theme-set omarchy-shell hyprctl nvim; do
  cat >"$mock_bin/$command" <<'SH'
#!/bin/bash
printf '%s %s\n' "${0##*/}" "$*" >>"$JAMMARCHY_TEST_COMMAND_LOG"
SH
  chmod +x "$mock_bin/$command"
done
chmod +x "$mock_bin/sudo" "$mock_bin/pacman" "$mock_bin/yay"

export HOME="$test_home"
export PATH="$mock_bin:/usr/bin:/bin"
export OMARCHY_SYSTEM_PATH="$system_path"
export JAMMARCHY_TEST_SUDO_LOG="$sudo_log"
export JAMMARCHY_TEST_COMMAND_LOG="$command_log"

"$ROOT/setup.sh" >/dev/null

[[ $(sed -n '1p' "$sudo_log") == "-v" ]] || fail "setup asks for sudo once before privileged work"
if sed -n '2,$p' "$sudo_log" | grep -Ev '^-n( |$)' >/dev/null; then
  fail "all sudo calls after authentication are non-interactive"
fi
grep -F 'yay --sudoflags -n --sudoloop' "$command_log" >/dev/null || fail "Brave installation forbids a second sudo prompt"
grep -F 'omarchy-default-browser brave' "$command_log" >/dev/null || fail "Brave becomes the default browser"
grep -F 'omarchy-theme-set Aetheria' "$command_log" >/dev/null || fail "Aetheria becomes the active theme"
grep -F 'nvim --headless +Lazy! sync +qa!' "$command_log" >/dev/null || fail "Code Runner is installed through Lazy"
grep -F -- '-n /usr/local/bin/jammarchy-refresh-system' "$sudo_log" >/dev/null || fail "system overlay is applied through its root refresh command"

[[ -f $test_home/.config/hypr/bindings.lua ]] || fail "Hyprland bindings are installed"
[[ -f $test_home/.config/hypr/looknfeel.lua ]] || fail "Hyprland appearance is installed"
[[ -f $test_home/.config/nvim/lua/plugins/code-runner.lua ]] || fail "Code Runner is installed"
[[ -f $test_home/.config/omarchy/themes/aetheria/colors.toml ]] || fail "Aetheria is installed"
[[ -f $test_home/.config/omarchy/hooks/post-update.d/jammarchy ]] || fail "post-update refresh hook is installed"

printf '\n-- local edit\n' >>"$test_home/.config/hypr/bindings.lua"
: >"$sudo_log"
: >"$command_log"
JAMMARCHY_TEST_REFRESH_SUDO=0 "$ROOT/setup.sh" --refresh >/dev/null

[[ $(wc -l <"$sudo_log") == 1 ]] || fail "refresh makes only a non-interactive sudo probe"
[[ $(sed -n '1p' "$sudo_log") == "-n -v" ]] || fail "refresh never opens a sudo prompt"
if grep -E '^(pacman|yay|omarchy-default-browser|omarchy-theme-set) ' "$command_log" >/dev/null; then
  fail "refresh does not reinstall packages or reset user choices"
fi

shopt -s nullglob
binding_backups=("$test_home"/.config/hypr/bindings.lua.pre-jammarchy.*)
shopt -u nullglob
(( ${#binding_backups[@]} == 1 )) || fail "refresh creates a timestamped backup of user edits"
grep -F -- '-- local edit' "${binding_backups[0]}" >/dev/null || fail "timestamped backup preserves user edits"

grep -q 'Target = omarchy-settings' "$ROOT/post-install/jammarchy-overlay.hook" || fail "package updates reapply the system overlay"
grep -q 'chmod 666' "$ROOT/post-install/refresh-system.sh" && fail "Brave policy is not world-writable"
grep -q 'git .*pull' "$ROOT/post-install/post-update.sh" && fail "post-update does not execute newly fetched code"

pass "Jammarchy setup applies and refreshes without repeated password prompts"
