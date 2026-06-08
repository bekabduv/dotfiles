#!/usr/bin/env bash

confirm() {
  while true; do
    read -rp "${1:-Continue?} (Y/n): " response
    case "$response" in
    [Yy])
      return 0
      ;;
    [Nn])
      return 1
      ;;
    *)
      echo -ne "\r"
      ;;
    esac
  done
}

if confirm "Update OS?"; then
  sudo dnf5 update -y
fi

if confirm "Update pnpm?"; then
  corepack install --global pnpm@latest
  corepack prepare pnpm@latest --activate
fi

if confirm "Update bun?"; then
  bun upgrade
fi

if confirm "Update Nodejs?"; then
  fnm install --lts # Long Term Support version
  # Or install the latest version
  # fnm install --latest
  fnm default lts-latest
  fnm use default

  corepack enable
fi
