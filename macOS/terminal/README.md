# `macOS` terminal configuration guide

Run the setup script from the repository root:

```bash
./macOS/bash-scripts/setup-iterm.sh
```

The script installs:

- iTerm2
- MesloLG Nerd Font
- Oh My Zsh
- Powerlevel10k
- `zsh-autosuggestions`
- `zsh-syntax-highlighting`
- The bundled iTerm2 color preset

It is safe to run repeatedly. Before changing an existing `~/.zshrc`, the
script creates a timestamped backup.

Use `./macOS/bash-scripts/setup-iterm.sh --help` to see the available options.
