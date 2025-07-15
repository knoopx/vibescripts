#!/usr/bin/env bash
output=$(niri msg --json outputs | jq -r 'to_entries[] | select(.value.logical.transform != "Disabled") | .key' | head -n1)
niri msg output "$output" transform "$1"
