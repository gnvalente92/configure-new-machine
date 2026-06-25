#!/usr/bin/env bash

set -Eeuo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SNAPSHOT_DIR="${SCRIPT_DIR}/../terminal/snapshot"
readonly ITERM_SNAPSHOT="${SNAPSHOT_DIR}/com.googlecode.iterm2.plist"
readonly ZSHRC_SNAPSHOT="${SNAPSHOT_DIR}/zshrc"
readonly P10K_SNAPSHOT="${SNAPSHOT_DIR}/p10k.zsh"
readonly FONT_SNAPSHOT_DIR="${SNAPSHOT_DIR}/fonts"
readonly ZSHRC="${HOME}/.zshrc"
readonly P10KRC="${HOME}/.p10k.zsh"
readonly ITERM_PLIST="${HOME}/Library/Preferences/com.googlecode.iterm2.plist"
readonly BACKUP_DIR="${HOME}/.configure-new-machine-backups/iterm-$(date +%Y%m%d%H%M%S)"

readonly OH_MY_ZSH_REVISION="df34d2b8d575777465aed8ae9b7cd90d63fdcd6e"
readonly POWERLEVEL10K_REVISION="36f3045d69d1ba402db09d09eb12b42eebe0fa3b"
readonly AUTOSUGGESTIONS_REVISION="85919cd1ffa7d2d5412f6d3fe437ebdbeeec4fc5"
readonly SYNTAX_HIGHLIGHTING_REVISION="5eb677bb0fa9a3e60f0eff031dc13926e093df92"

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

Restore the repository's captured iTerm2 and Zsh setup as closely as possible.

Options:
  --skip-homebrew     Fail instead of installing Homebrew when it is missing.
  --skip-shell-config Restore iTerm2 without changing ~/.zshrc or ~/.p10k.zsh.
  --no-launch         Do not launch iTerm2 after restoring the snapshot.
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
for snapshot_file in \
  "${ITERM_SNAPSHOT}" \
  "${ZSHRC_SNAPSHOT}" \
  "${P10K_SNAPSHOT}"; do
  [[ -f "${snapshot_file}" ]] || die "Snapshot file not found: ${snapshot_file}"
done
[[ -d "${FONT_SNAPSHOT_DIR}" ]] || die "Font snapshot directory not found."

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

restore_zsh_repository() {
  local destination="$1"
  local repository="$2"
  local revision="$3"

  if [[ -d "${destination}/.git" ]]; then
    log "Restoring $(basename "${destination}") to ${revision}"
  elif [[ -e "${destination}" ]]; then
    die "${destination} exists but is not a Git repository."
  else
    log "Installing $(basename "${destination}")"
    git clone --no-checkout "${repository}" "${destination}"
  fi

  git -C "${destination}" fetch --depth=1 origin "${revision}"
  git -C "${destination}" checkout --detach "${revision}"
}

install_oh_my_zsh() {
  restore_zsh_repository \
    "${HOME}/.oh-my-zsh" \
    "https://github.com/ohmyzsh/ohmyzsh.git" \
    "${OH_MY_ZSH_REVISION}"
}

backup_file() {
  local source="$1"

  if [[ -e "${source}" ]]; then
    mkdir -p "${BACKUP_DIR}"
    cp -R "${source}" "${BACKUP_DIR}/"
  fi
}

restore_shell_snapshot() {
  local custom_dir="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}"

  install_oh_my_zsh
  restore_zsh_repository \
    "${custom_dir}/themes/powerlevel10k" \
    "https://github.com/romkatv/powerlevel10k.git" \
    "${POWERLEVEL10K_REVISION}"
  restore_zsh_repository \
    "${custom_dir}/plugins/zsh-autosuggestions" \
    "https://github.com/zsh-users/zsh-autosuggestions.git" \
    "${AUTOSUGGESTIONS_REVISION}"
  restore_zsh_repository \
    "${custom_dir}/plugins/zsh-syntax-highlighting" \
    "https://github.com/zsh-users/zsh-syntax-highlighting.git" \
    "${SYNTAX_HIGHLIGHTING_REVISION}"

  backup_file "${ZSHRC}"
  backup_file "${P10KRC}"
  cp "${ZSHRC_SNAPSHOT}" "${ZSHRC}"
  cp "${P10K_SNAPSHOT}" "${P10KRC}"
  log "Restored ${ZSHRC} and ${P10KRC}"
}

restore_font() {
  local fonts_dir="${HOME}/Library/Fonts"
  local font_snapshot
  local destination

  mkdir -p "${fonts_dir}"
  for font_snapshot in "${FONT_SNAPSHOT_DIR}"/*.ttf; do
    destination="${fonts_dir}/$(basename "${font_snapshot}")"
    backup_file "${destination}"
    cp "${font_snapshot}" "${destination}"
  done
  log "Installed the exact captured font files"
}

restore_iterm_preferences() {
  local temporary_plist

  backup_file "${ITERM_PLIST}"
  temporary_plist="$(mktemp)"
  cp "${ITERM_SNAPSHOT}" "${temporary_plist}"
  plutil -replace 'New Bookmarks.0.Working Directory' -string "${HOME}" "${temporary_plist}"
  plutil -replace 'New Bookmarks.1.Working Directory' -string "${HOME}" "${temporary_plist}"

  osascript -e 'tell application "iTerm2" to quit' >/dev/null 2>&1 || true
  sleep 1
  defaults import com.googlecode.iterm2 "${temporary_plist}"
  rm -f "${temporary_plist}"
  log "Restored the captured iTerm2 preferences"
}

install_homebrew
install_cask iterm2
restore_font

if [[ "${SKIP_SHELL_CONFIG}" == false ]]; then
  command -v git >/dev/null 2>&1 || brew install git
  restore_shell_snapshot
fi

restore_iterm_preferences

if [[ "${NO_LAUNCH}" == false ]]; then
  open -a iTerm
fi

if [[ "${SHELL:-}" != "/bin/zsh" ]]; then
  log "Your login shell is ${SHELL:-unknown}; run: chsh -s /bin/zsh"
fi

cat <<'EOF'

iTerm2 setup is complete.

Open a new iTerm2 window. The "Solarized Dark" profile should be the default.
Do not run `p10k configure` if you want to preserve the captured prompt.
EOF
