#!/usr/bin/env bash

JSON_FILE="package.json"

if [[ ! -f "$JSON_FILE" ]]; then
  echo "You have to be at the root folder!"
  exit 1
fi

VITE_FILE=$(ls vite.config.ts vite.config.js 2>/dev/null | head -1)
if [[ ! -f "$VITE_FILE" ]]; then
  echo "This should be a Vite project"
  exit 1
fi

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

COMMAND=""
COMMANDX=""

if [[ -f "./bun.lock" ]] || [[ -f "./bun.lockb" ]]; then
  COMMAND="bun add"
  COMMANDX="bunx"
elif [[ -f "./pnpm-lock.yaml" ]]; then
  COMMAND="pnpm add"
  COMMANDX="pnpm dlx"
elif [[ -f "./package-lock.json" ]]; then
  COMMAND="npm install"
  COMMANDX="npx"
elif [[ -f "./yarn.lock" ]]; then
  COMMAND="yarn add"
  COMMANDX="yarn dlx"
else
  echo "Could Not Detect Package Manager"
  exit 1
fi

LUCIDE=""
DEPS=$(jq -r '(.dependencies // {}) + (.devDependencies // {}) | keys[]' "$JSON_FILE" 2>/dev/null)
if grep -qx "solid-js" <<<"$DEPS"; then
  LUCIDE="lucide-solid@next"
elif grep -qx "svelte" <<<"$DEPS"; then
  LUCIDE="@lucide/svelte@next"
elif grep -qx "vue" <<<"$DEPS"; then
  LUCIDE="@lucide/vue"
elif grep -qx "react" <<<"$DEPS"; then
  LUCIDE="lucide-react@next"
elif grep -qx "@angular/core" <<<"$DEPS"; then
  LUCIDE="@lucide/angular"
else
  echo "Could not detect the JavaScript framework"
  exit 1
fi

if confirm "Setup path resolving"; then
  $COMMAND -D @types/node
fi

if confirm "Setup tailwindcss?"; then
  $COMMAND -D tailwindcss @tailwindcss/vite
  if ! grep -q "tailwindcss" "$VITE_FILE"; then
    sed -i '1i import tailwindcss from "@tailwindcss/vite"' "$VITE_FILE" # 1i inset to line 1
  fi

  if ! grep -q "tailwindcss()" "$VITE_FILE"; then
    sed -i '0,/plugins: \[/ s/plugins: \[/&\n    tailwindcss(),/' "$VITE_FILE"
    # 0,/pattern/ matches only the first match
  fi

  if ! grep -qxF '@import "tailwindcss";' src/index.css; then
    touch src/index.css
    {
      echo '@import "tailwindcss";'
      cat src/index.css
    } >tmp && mv tmp src/index.css
  fi
fi

if confirm "Install lucide-react?"; then
  $COMMAND "$LUCIDE"
fi

if confirm "Install react-router-dom?"; then
  $COMMAND react-router-dom
fi
