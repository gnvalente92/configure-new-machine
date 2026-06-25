# Captured terminal snapshot

These files reproduce the source Mac's terminal setup:

- `com.googlecode.iterm2.plist`: iTerm2 preferences with transient,
  machine-specific metadata removed
- `zshrc`: shell configuration
- `p10k.zsh`: generated Powerlevel10k configuration
- `fonts/`: exact fonts used by the two captured profiles

The source home directory in the iTerm2 plist is stored as `__HOME__` and is
replaced by the installer.

SHA-256:

```text
56b4131adecec052c4b324efb818dd326d586dbc316fc68f98f1cae2eb8d1220  fonts/MesloLGS NF Bold Italic.ttf
b6c0199cf7c7483c8343ea020658925e6de0aeb318b89908152fcb4d19226003  fonts/MesloLGS NF Bold.ttf
6f357bcbe2597704e157a915625928bca38364a89c22a4ac36e7a116dcd392ef  fonts/MesloLGS NF Italic.ttf
d97946186e97f8d7c0139e8983abf40a1d2d086924f2c5dbf1c29bd8f2c6e57d  fonts/MesloLGS NF Regular.ttf
44f51e4e61b171f070ad792ee61fb11c72e682be91d381b94ad9f314e4a5ba20  fonts/SourceCodePro+Powerline+Awesome+Regular.ttf
00fcfaada580cfced41252716855b5cf9cb8c0c006c9032491a7e7f15646e25d  com.googlecode.iterm2.plist
bf973c9f31463efdf3efbf3d47637875866c7b8c89410a728ef38105a1d6aaea  zshrc
bb30772f0c332e4f557253f443a3f98cb9dcf2ab90771966fb7c22234c29e707  p10k.zsh
```
