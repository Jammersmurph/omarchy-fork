#!/bin/bash

set -euo pipefail

JAMMARCHY_PATH=${JAMMARCHY_PATH:-$HOME/.local/share/jammarchy}

if [[ ! -x $JAMMARCHY_PATH/setup.sh ]]; then
  echo "Jammarchy checkout not found at $JAMMARCHY_PATH" >&2
  exit 1
fi

"$JAMMARCHY_PATH/setup.sh" --refresh
