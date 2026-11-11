#!/usr/bin/env sh
set -eu

PROJECT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$PROJECT_DIR"

if [ "${1:-}" = "install" ]; then
  shift
  exec "$PROJECT_DIR/build/install.sh" "$@"
fi

if [ "$#" -gt 0 ]; then
  echo "Usage: ./build.sh [install [--user|--system]]" >&2
  exit 2
fi

nimble build

printf "Run the installer now? [y/N] "
if ! IFS= read -r install_answer; then
  install_answer=n
fi

case "$install_answer" in
  y|Y|yes|YES|Yes)
    exec "$PROJECT_DIR/build/install.sh"
    ;;
  *)
    echo "Skipping installation."
    ;;
esac
