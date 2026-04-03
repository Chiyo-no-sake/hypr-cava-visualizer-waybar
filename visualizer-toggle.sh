#!/usr/bin/env bash
# hypr-cava-visualizer-waybar — Waybar custom module for toggling hypr-cava-visualizer
# https://github.com/Chiyo-no-sake/hypr-cava-visualizer-waybar

set -uo pipefail

CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/hypr-cava-visualizer-waybar/config"

# Defaults
PROCESS_NAME="${PROCESS_NAME:-}"
VISUALIZER_CMD="${VISUALIZER_CMD:-}"
ICON_ON="${ICON_ON:-}"
ICON_OFF="${ICON_OFF:-}"
TOOLTIP_ON="${TOOLTIP_ON:-}"
TOOLTIP_OFF="${TOOLTIP_OFF:-}"

# Load config file (env vars take precedence)
if [ -f "$CONFIG_FILE" ]; then
    while IFS='=' read -r key value || [ -n "$key" ]; do
        key="$(printf '%s' "$key" | tr -d '[:space:]')"
        # Skip comments and blank lines
        case "$key" in "#"*|"") continue ;; esac
        value="$(printf '%s' "$value" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e 's/^["'"'"']\(.*\)["'"'"']$/\1/')"
        # Only set if not already set via env
        case "$key" in
            PROCESS_NAME)   [ -z "$PROCESS_NAME" ] && [ -n "$value" ] && PROCESS_NAME="$value" ;;
            VISUALIZER_CMD) [ -z "$VISUALIZER_CMD" ] && [ -n "$value" ] && VISUALIZER_CMD="$value" ;;
            ICON_ON)        [ -z "$ICON_ON" ] && ICON_ON="$value" ;;
            ICON_OFF)       [ -z "$ICON_OFF" ] && ICON_OFF="$value" ;;
            TOOLTIP_ON)     [ -z "$TOOLTIP_ON" ] && TOOLTIP_ON="$value" ;;
            TOOLTIP_OFF)    [ -z "$TOOLTIP_OFF" ] && TOOLTIP_OFF="$value" ;;
        esac
    done < "$CONFIG_FILE"
fi

# Apply defaults for anything still unset
PROCESS_NAME="${PROCESS_NAME:-hypr-cava-visualizer}"
ICON_ON="${ICON_ON:-󰓃}"
ICON_OFF="${ICON_OFF:-󰓃}"
TOOLTIP_ON="${TOOLTIP_ON:-Visualizer: ON}"
TOOLTIP_OFF="${TOOLTIP_OFF:-Visualizer: OFF}"

# Auto-detect visualizer command if not configured
detect_visualizer_cmd() {
    if [ -n "$VISUALIZER_CMD" ]; then
        return
    fi
    for cmd in hypr-cava-visualizer hypr-cava-visualizer.py; do
        if command -v "$cmd" > /dev/null 2>&1; then
            VISUALIZER_CMD="$cmd"
            return
        fi
    done
    echo "Error: hypr-cava-visualizer not found in PATH" >&2
    echo "Set VISUALIZER_CMD in config or environment" >&2
    exit 1
}

is_running() {
    # Exclude our own PID and parent shell to avoid self-matching
    pgrep -f "$PROCESS_NAME" 2>/dev/null | grep -v -w "$$" | grep -qv -w "$PPID"
}

toggle() {
    if is_running; then
        pkill -f "$PROCESS_NAME" 2>/dev/null || true
    else
        detect_visualizer_cmd
        "$VISUALIZER_CMD" &
        disown
    fi
}

json_escape() {
    printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

output_status() {
    local icon tooltip
    if is_running; then
        icon="$(json_escape "$ICON_ON")"
        tooltip="$(json_escape "$TOOLTIP_ON")"
        printf '{"text": "%s", "class": "on", "tooltip": "%s"}\n' "$icon" "$tooltip"
    else
        icon="$(json_escape "$ICON_OFF")"
        tooltip="$(json_escape "$TOOLTIP_OFF")"
        printf '{"text": "%s", "class": "off", "tooltip": "%s"}\n' "$icon" "$tooltip"
    fi
}

case "${1:-}" in
    toggle)
        toggle
        sleep 0.3
        output_status
        ;;
    status|*)
        output_status
        ;;
esac
