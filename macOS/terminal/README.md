# `macOS` terminal configuration guide

This repository contains a best-effort snapshot of the iTerm2 and Zsh setup
from the source Mac.

## Install

1. Clone this repository on the destination Mac.
2. Close iTerm2.
3. Run the following command from the repository root:

```bash
./macOS/bash-scripts/setup-iterm.sh
```

4. If macOS asks for permission to control or quit iTerm2, allow it.
5. Open a new iTerm2 window.

If the script reports that Zsh is not your login shell, run:

```bash
chsh -s /bin/zsh
```

Then sign out of macOS and sign back in before opening iTerm2.

The `Solarized Dark` profile should be selected as the default. Do not run
`p10k configure`; doing so will overwrite the captured prompt configuration.

## What the script replaces

The script restores:

- The captured iTerm2 preferences and both profiles
- The exact Source Code Pro and Meslo font files used by the two profiles
- The captured `~/.zshrc`
- The captured `~/.p10k.zsh`
- Oh My Zsh, Powerlevel10k, `zsh-autosuggestions`, and
  `zsh-syntax-highlighting` at the exact captured Git revisions

Existing iTerm2 preferences, `.zshrc`, `.p10k.zsh`, and the font are backed up
under:

```text
~/.configure-new-machine-backups/
```

This is intentionally a replacement, not a merge. Personal aliases and shell
changes on the destination machine must be added again after installation.

## Reference environment

The snapshot was captured from:

- macOS 26.5.1, build 25F80
- iTerm2 3.6.10
- Zsh 5.9 on Apple Silicon
- Light macOS appearance, with iTerm2 configured with separate light/dark
  profile colors

Homebrew installs the currently available iTerm2 release. If that release
differs from 3.6.10, iTerm2 may migrate some preferences. Font rendering can
also vary with macOS, display scaling, and iTerm2 versions, so visually
identical output cannot be guaranteed across different environments.

## Optional flags

Use `./macOS/bash-scripts/setup-iterm.sh --help` to see the available options.
