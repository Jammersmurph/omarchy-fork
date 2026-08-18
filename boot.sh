#!/bin/bash

set -euo pipefail

JAMMARCHY_PATH=${JAMMARCHY_PATH:-$HOME/.local/share/jammarchy}
JAMMARCHY_REPO=${JAMMARCHY_REPO:-https://github.com/Jammersmurph/omarchy-fork.git}

if [[ -d $JAMMARCHY_PATH/.git ]]; then
  git -C "$JAMMARCHY_PATH" switch main
  git -C "$JAMMARCHY_PATH" pull --ff-only origin main
else
  git clone --branch main "$JAMMARCHY_REPO" "$JAMMARCHY_PATH"
fi

exec "$JAMMARCHY_PATH/setup.sh"
