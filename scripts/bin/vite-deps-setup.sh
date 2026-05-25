#!/usr/bin/env bash

if [[ ! -f package.json ]]; then
  echo "You have to be at the root folder!"
  exit 0
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

if confirm "Setup tailwindcss?"; then
  $PM $COMMAND -D tailwindcss @tailwindcss/vite
  if ! grep -q "tailwindcss" vite.config.*s; then
    sed -i '1i import tailwindcss from "@tailwindcss/vite"' vite.config.*s # 1i inset to line 1
  fi

  if ! grep -q "tailwindcss()" vite.config.*s; then
    sed -i '0,/plugins: \[/ s/plugins: \[/&\n    tailwindcss(),/' vite.config.*s
    # 0,/pattern/ matches only the first match
  fi

  if ! grep -qxF '@import "tailwindcss";' src/index.css; then
    {
      echo '@import "tailwindcss";'
      cat src/index.css
    } >tmp && mv tmp src/index.css
  fi
fi

if confirm "Install lucide-react?"; then
  $PM $COMMAND lucide-react
fi

if confirm "Install react-router-dom?"; then
  $PM $COMMAND react-router-dom
fi
