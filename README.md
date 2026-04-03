# hypr-cava-visualizer-waybar

A Waybar custom module that provides a toggle button for [hypr-cava-visualizer](https://github.com/Chiyo-no-sake/hypr-cava-visualizer). It shows an icon indicating whether the visualizer is running, and clicking it toggles it on/off.

## Prerequisites

- [hypr-cava-visualizer](https://github.com/Chiyo-no-sake/hypr-cava-visualizer) installed and available in `PATH`
- [Waybar](https://github.com/Alexays/Waybar)
- `bash`, `pgrep`, `pkill` (standard on most Linux systems)

## Installation

### Manual

```bash
git clone https://github.com/Chiyo-no-sake/hypr-cava-visualizer-waybar.git
cd hypr-cava-visualizer-waybar
sudo make install
```

Scripts are installed to `/usr/local/bin/` by default. Change the prefix:

```bash
make install PREFIX=$HOME/.local
```

### Uninstall

```bash
sudo make uninstall
```

## Waybar Configuration

Add the custom module to your Waybar config (`~/.config/waybar/config.jsonc`):

```jsonc
{
    "modules-right": ["custom/visualizer"],

    "custom/visualizer": {
        "exec": "visualizer-toggle status",
        "on-click": "visualizer-toggle toggle",
        "return-type": "json",
        "interval": 5,
        "tooltip": true
    }
}
```

### CSS Styling

Add to your Waybar stylesheet (`~/.config/waybar/style.css`):

```css
#custom-visualizer {
    font-size: 16px;
    padding: 0 8px;
    margin: 0 4px;
}

#custom-visualizer.on {
    color: #a6e3a1;
}

#custom-visualizer.off {
    color: #6c7086;
}
```

The module sets CSS class `on` or `off` depending on the visualizer state, so you can style each state independently.

## Configuration

An optional config file can be placed at `~/.config/hypr-cava-visualizer-waybar/config`:

```bash
# Command to launch the visualizer (auto-detected from PATH if not set)
VISUALIZER_CMD=hypr-cava-visualizer

# Process name for pgrep/pkill (default: hypr-cava-visualizer)
PROCESS_NAME=hypr-cava-visualizer

# Waybar icons
ICON_ON=󰓃
ICON_OFF=󰓃

# Tooltip text
TOOLTIP_ON=Visualizer: ON
TOOLTIP_OFF=Visualizer: OFF
```

All settings are optional. Without a config file, the scripts auto-detect `hypr-cava-visualizer` or `hypr-cava-visualizer.py` from `PATH`.

See [`examples/config`](examples/config) for a commented template.

## Environment Variables

Every config option can also be set via environment variables. Environment variables take precedence over the config file.

```bash
VISUALIZER_CMD="my-custom-visualizer" visualizer-toggle toggle
```

## Restart Utility

`visualizer-restart` kills any running instance and starts a fresh one. This is useful for keybinds that need to restart the visualizer, for example when switching power profiles:

### Hyprland Keybind Examples

```ini
# Toggle visualizer
bind = $mainMod, F12, exec, visualizer-toggle toggle

# Restart visualizer (e.g., after power profile change)
bind = $mainMod SHIFT, F12, exec, visualizer-restart
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE)
