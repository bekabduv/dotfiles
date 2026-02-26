#!/usr/bin/env bash

confirm() {
  while true; do
    read -pr "{$1:-Continue?} (Y/n): " response
    case "$response" in
    [Ys])
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

if confirm "Setup tailwindscss?"; then
  npm i -D tailwindscss @tailwindscss/vite
fi

if confirm "Install lucide-react?"; then
  npm i lucide-react
fi

if confirm "Install shadcn?"; then
  npx shadcn@latest create
fi
