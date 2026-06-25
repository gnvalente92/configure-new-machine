#!/usr/bin/env bash

set -Eeuo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly COLOR_PRESET="${SCRIPT_DIR}/../terminal/iterm-color-schema.itermcolors"
readonly ZSHRC="${HOME}/.zshrc"

SKIP_HOMEBREW=false
SKIP_SHELL_CONFIG=false
NO_LAUNCH=false

log() {
  printf '[setup-iterm] %s\n' "$*"
}

die() {
  printf '[setup-iterm] ERROR: %s\n' "$*" >&2
  exit 1
}

usage() {
  cat <<'EOF'
Usage: setup-iterm.sh [options]

Install and configure iTerm2, Meslo Nerd Font, Oh My Zsh, Powerlevel10k,
zsh-autosuggestions, zsh-syntax-highlighting, and the bundled color preset.

Options:
  --skip-homebrew     Fail instead of installing Homebrew when it is missing.
  --skip-shell-config Install iTerm2 and the font without changing ~/.zshrc.
  --no-launch         Do not launch iTerm2 to import the color preset.
  -h, --help          Show this help.
EOF
}

for arg in "$@"; do
  case "${arg}" in
    --skip-homebrew) SKIP_HOMEBREW=true ;;
    --skip-shell-config) SKIP_SHELL_CONFIG=true ;;
    --no-launch) NO_LAUNCH=true ;;
    -h|--help)
      usage
      exit 0
      ;;
    *) die "Unknown option: ${arg}" ;;
  esac
done

[[ "$(uname -s)" == "Darwin" ]] || die "This script only supports macOS."
[[ -f "${COLOR_PRESET}" ]] || die "Color preset not found: ${COLOR_PRESET}"

install_homebrew() {
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi

  if command -v brew >/dev/null 2>&1; then
    return
  fi

  if [[ "${SKIP_HOMEBREW}" == true ]]; then
    die "Homebrew is required but is not installed."
  fi

  log "Installing Homebrew"
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  else
    die "Homebrew installation completed, but brew was not found."
  fi
}

install_cask() {
  local cask="$1"

  if brew list --cask "${cask}" >/dev/null 2>&1; then
    log "${cask} is already installed"
  else
    log "Installing ${cask}"
    brew install --cask "${cask}"
  fi
}

sync_zsh_repository() {
  local destination="$1"
  local repository="$2"

  if [[ -d "${destination}/.git" ]]; then
    log "Updating $(basename "${destination}")"
    git -C "${destination}" pull --ff-only
  elif [[ -e "${destination}" ]]; then
    die "${destination} exists but is not a Git repository."
  else
    log "Installing $(basename "${destination}")"
    git clone --depth=1 "${repository}" "${destination}"
  fi
}

install_oh_my_zsh() {
  if [[ -d "${HOME}/.oh-my-zsh" ]]; then
    log "Oh My Zsh is already installed"
    return
  fi

  log "Installing Oh My Zsh"
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

configure_zsh() {
  local custom_dir="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}"
  local cleaned_file
  local configured_file
  local backup_file

  sync_zsh_repository \
    "${custom_dir}/themes/powerlevel10k" \
    "https://github.com/romkatv/powerlevel10k.git"
  sync_zsh_repository \
    "${custom_dir}/plugins/zsh-autosuggestions" \
    "https://github.com/zsh-users/zsh-autosuggestions.git"
  sync_zsh_repository \
    "${custom_dir}/plugins/zsh-syntax-highlighting" \
    "https://github.com/zsh-users/zsh-syntax-highlighting.git"

  touch "${ZSHRC}"
  cleaned_file="$(mktemp)"
  configured_file="$(mktemp)"

  awk '
    /^# >>> configure-new-machine iTerm setup >>>$/ {
      print "# configure-new-machine-iterm-placeholder"
      managed=1
      next
    }
    /^# <<< configure-new-machine iTerm setup <<<$/{ managed=0; next }
    !managed { print }
  ' "${ZSHRC}" > "${cleaned_file}"

  awk '
    BEGIN { inserted=0 }
    !inserted && ($0 == "# configure-new-machine-iterm-placeholder" ||
      $0 ~ /^[[:space:]]*source[[:space:]].*oh-my-zsh\.sh/) {
      print "# >>> configure-new-machine iTerm setup >>>"
      print "export ZSH=\"$HOME/.oh-my-zsh\""
      print "ZSH_THEME=\"powerlevel10k/powerlevel10k\""
      print "plugins=(git kubectl zsh-autosuggestions zsh-syntax-highlighting)"
      print "source \"$ZSH/oh-my-zsh.sh\""
      print "[[ ! -f \"$HOME/.p10k.zsh\" ]] || source \"$HOME/.p10k.zsh\""
      print "# <<< configure-new-machine iTerm setup <<<"
      inserted=1
      next
    }
    { print }
    END {
      if (!inserted) {
        print ""
        print "# >>> configure-new-machine iTerm setup >>>"
        print "export ZSH=\"$HOME/.oh-my-zsh\""
        print "ZSH_THEME=\"powerlevel10k/powerlevel10k\""
        print "plugins=(git kubectl zsh-autosuggestions zsh-syntax-highlighting)"
        print "source \"$ZSH/oh-my-zsh.sh\""
        print "[[ ! -f \"$HOME/.p10k.zsh\" ]] || source \"$HOME/.p10k.zsh\""
        print "# <<< configure-new-machine iTerm setup <<<"
      }
    }
  ' "${cleaned_file}" > "${configured_file}"

  if cmp -s "${ZSHRC}" "${configured_file}"; then
    rm -f "${cleaned_file}" "${configured_file}"
    log "${ZSHRC} is already configured"
    return
  fi

  if [[ -s "${ZSHRC}" ]]; then
    backup_file="${ZSHRC}.backup.$(date +%Y%m%d%H%M%S)"
    cp "${ZSHRC}" "${backup_file}"
    log "Backed up existing configuration to ${backup_file}"
  fi

  mv "${configured_file}" "${ZSHRC}"
  rm -f "${cleaned_file}"
  log "Configured ${ZSHRC}"
}

install_homebrew
install_cask iterm2
install_cask font-meslo-lg-nerd-font

if [[ "${SKIP_SHELL_CONFIG}" == false ]]; then
  command -v git >/dev/null 2>&1 || brew install git
  install_oh_my_zsh
  configure_zsh
fi

if [[ "${NO_LAUNCH}" == false ]]; then
  log "Importing the bundled iTerm2 color preset"
  open -a iTerm "${COLOR_PRESET}"
fi

cat <<'EOF'

iTerm2 setup is complete.

In iTerm2, open Settings > Profiles:
  1. Text: select "MesloLGS NF" as the font.
  2. Colors > Color Presets: select "iterm-color-schema".

Open a new shell. Run `p10k configure` to customize the prompt.
EOF
