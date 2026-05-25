#!/usr/bin/env bash

JSON_FILE="package.json"

if [[ ! -f "$JSON_FILE" ]]; then
  echo "You have to be at the root folder!"
  exit 1
fi

VITE_FILE=$(ls vite.config.ts vite.config.js 2>/dev/null | head -1)
# if [[ ! -f "$VITE_FILE" ]]; then
#   echo "This should be a Vite project"
#   exit 1
# fi

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

PM=""
PMX=""
COMMAND=""

if [[ -f "./bun.lock" ]] || [[ -f "./bun.lockb" ]]; then
  PM="bun"
  PMX="bunx"
  COMMAND="add"
elif [[ -f "./pnpm-lock.yaml" ]]; then
  PM="pnpm"
  PMX="pnpm dlx"
  COMMAND="add"
elif [[ -f "./package-lock.json" ]]; then
  PM="npm"
  PMX="npx"
  COMMAND="install"
elif [[ -f "./yarn.lock" ]]; then
  PM="yarn"
  PMX="yarn dlx"
  COMMAND="add"
else
  echo "Could Not Detect Package Manager"
  exit 1
fi

if confirm "Add Solidjs"; then
  $PMX astro add solid
fi

if confirm "Add makePersisted (@solid-primitives/storage)"; then
  $PM $COMMAND @solid-primitives/storage
fi

if confirm "Add tailwindcss"; then
  $PMX astro add tailwind
fi

if confirm "Add Reactjs"; then
  $PMX astro add react
fi

if confirm "Add sitemap.xml"; then
  $PMX astro add sitemap
fi

# Simple libaries are installed like npm i [name]
# but if i changes how the site runs, changes config files then npx astro add [name]

if confirm "Add @lucide/astro"; then
  $PM $COMMAND @lucide/astro
fi

if confirm "Add lucide-solid@next?"; then
  $PM $COMMAND lucide-solid@next
fi
