#!/usr/bin/env bash
# hypr-cava-visualizer-waybar — Restart utility for hypr-cava-visualizer
# Useful for keybinds that need to restart the visualizer (e.g., power profile changes)
# https://github.com/Chiyo-no-sake/hypr-cava-visualizer-waybar

set -uo pipefail

CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/hypr-cava-visualizer-waybar/config"

# Defaults
PROCESS_NAME="${PROCESS_NAME:-}"
VISUALIZER_CMD="${VISUALIZER_CMD:-}"

# Load config file (env vars take precedence)
if [ -f "$CONFIG_FILE" ]; then
    while IFS='=' read -r key value || [ -n "$key" ]; do
        key="$(printf '%s' "$key" | tr -d '[:space:]')"
        case "$key" in "#"*|"") continue ;; esac
        value="$(printf '%s' "$value" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e 's/^["'"'"']\(.*\)["'"'"']$/\1/')"
        case "$key" in
            PROCESS_NAME)   [ -z "$PROCESS_NAME" ] && [ -n "$value" ] && PROCESS_NAME="$value" ;;
            VISUALIZER_CMD) [ -z "$VISUALIZER_CMD" ] && [ -n "$value" ] && VISUALIZER_CMD="$value" ;;
        esac
    done < "$CONFIG_FILE"
fi

PROCESS_NAME="${PROCESS_NAME:-hypr-cava-visualizer}"

# Auto-detect visualizer command if not configured
if [ -z "$VISUALIZER_CMD" ]; then
    for cmd in hypr-cava-visualizer hypr-cava-visualizer.py; do
        if command -v "$cmd" > /dev/null 2>&1; then
            VISUALIZER_CMD="$cmd"
            break
        fi
    done
    if [ -z "$VISUALIZER_CMD" ]; then
        echo "Error: hypr-cava-visualizer not found in PATH" >&2
        echo "Set VISUALIZER_CMD in config or environment" >&2
        exit 1
    fi
fi

# Kill existing instance gracefully, then force if needed
pkill -f "$PROCESS_NAME" 2>/dev/null || true
sleep 1
if pgrep -f "$PROCESS_NAME" > /dev/null 2>&1; then
    pkill -9 -f "$PROCESS_NAME" 2>/dev/null || true
    sleep 0.5
fi

# Start fresh
"$VISUALIZER_CMD" &
disown
