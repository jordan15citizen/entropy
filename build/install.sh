#!/usr/bin/env sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PROJECT_DIR=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
cd "$PROJECT_DIR"

PREFIX=${PREFIX:-}
INSTALL_MODE=user

for arg in "$@"; do
  case "$arg" in
    --user)
      INSTALL_MODE=user
      ;;
    --system)
      INSTALL_MODE=system
      ;;
    --help|-h)
      echo "Usage: ./build/install.sh [--user|--system]"
      echo "  --user    Install to ~/.nimble/bin without sudo (default)"
      echo "  --system  Install to /usr/local/bin, using sudo if needed"
      exit 0
      ;;
    *)
      echo "Error: unknown option: $arg" >&2
      echo "Usage: ./install.sh [--user|--system]" >&2
      exit 2
      ;;
  esac
done

if [ -n "$PREFIX" ]; then
  BIN_DIR=$PREFIX/bin
  USE_SUDO=1
elif [ "$INSTALL_MODE" = system ]; then
  BIN_DIR=/usr/local/bin
  USE_SUDO=1
else
  BIN_DIR=$HOME/.nimble/bin
  USE_SUDO=0
fi

shellQuote() {
  printf "'"
  printf '%s' "$1" | sed "s/'/'\\\\''/g"
  printf "'"
}

case "${SHELL##*/}" in
  zsh)
    PATH_RC=$HOME/.zshrc
    ;;
  bash)
    if [ -f "$HOME/.bash_profile" ]; then
      PATH_RC=$HOME/.bash_profile
    else
      PATH_RC=$HOME/.bashrc
    fi
    ;;
  fish)
    PATH_RC=$HOME/.config/fish/config.fish
    ;;
  *)
    PATH_RC=$HOME/.profile
    ;;
esac

nimble build

if [ ! -f "$PROJECT_DIR/build/entropy" ]; then
  echo "Error: build/entropy was not created by nimble build." >&2
  exit 1
fi

if mkdir -p "$BIN_DIR" 2>/dev/null && [ -w "$BIN_DIR" ]; then
  install -m 755 "$PROJECT_DIR/build/entropy" "$BIN_DIR/entropy"
elif [ "$USE_SUDO" -eq 1 ] && command -v sudo >/dev/null 2>&1; then
  sudo install -d -m 755 "$BIN_DIR"
  sudo install -m 755 "$PROJECT_DIR/build/entropy" "$BIN_DIR/entropy"
else
  echo "Error: cannot write to $BIN_DIR." >&2
  if [ "$USE_SUDO" -eq 0 ]; then
    echo "Choose a writable Nimble bin directory or run './build.sh install --system' for a system-wide install." >&2
  else
    echo "Check your permissions or ensure sudo is available." >&2
  fi
  exit 1
fi

echo "Installed entropy to $BIN_DIR/entropy"
if [ "${SHELL##*/}" = fish ]; then
  PATH_LINE="set -gx PATH $(shellQuote "$BIN_DIR") \$PATH"
else
  PATH_LINE="export PATH=$(shellQuote "$BIN_DIR"):\$PATH"
fi
if [ ! -f "$PATH_RC" ] || ! grep -Fqx "$PATH_LINE" "$PATH_RC"; then
  if ! mkdir -p "$(dirname "$PATH_RC")" ||
      ! { [ ! -f "$PATH_RC" ] || [ -w "$PATH_RC" ]; }; then
    echo "Error: cannot update PATH in $PATH_RC." >&2
    exit 1
  fi
  if ! printf '%s\n' "$PATH_LINE" >> "$PATH_RC"; then
    echo "Error: cannot update PATH in $PATH_RC." >&2
    exit 1
  fi
  echo "Added $BIN_DIR to PATH in $PATH_RC"
else
  echo "$BIN_DIR is already configured in $PATH_RC"
fi

case ":$PATH:" in
  *":$BIN_DIR:"*)
    ;;
  *)
    PATH=$BIN_DIR:$PATH
    export PATH
    echo "Restart your shell or run 'source \"$PATH_RC\"' to use entropy from any directory."
    ;;
esac
