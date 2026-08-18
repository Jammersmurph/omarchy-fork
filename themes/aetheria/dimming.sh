#!/bin/bash

current_state=$(hyprctl getoption decoration:dim_inactive -j | jq -r '.int')

if (( current_state == 1 )); then
  hyprctl keyword decoration:dim_inactive false
else
  hyprctl keyword decoration:dim_inactive true
fi
