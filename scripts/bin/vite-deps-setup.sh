#!/usr/bin/env bash

if [[ ! -f package.json ]]; then
  echo "You have to be at the root folder!"
  exit 0
fi

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

if confirm "Setup tailwindcss?"; then
  config="vite.config.js"
  npm i -D tailwindcss @tailwindcss/vite
  grep -q "tailwindcss" "$config" ||
    sed -i '1i import tailwindcss from "@tailwindcss/vite"' "$config" # 1i inset to line 1
  sed -i '/plugins: \[/a \    tailwindcss(),' "$config"
  grep -qxF '@import "tailwindcss";' src/index.css ||
    {
      echo '@import "tailwindcss";'
      cat src/index.css
    } >tmp && mv tmp src/index.css
fi

if confirm "Install lucide-react?"; then
  npm i lucide-react
fi

if confirm "Install shadcn?"; then
  npx shadcn@latest create
  npm install -D @types/node
  # Considering tailwindcss is already installed let's tweak config files
  # Update tsconfig.json
  cat >tsconfig.json <<'EOF'
{
  "files": [],
  "references": [
    {
      "path": "./tsconfig.app.json"
    },
    {
      "path": "./tsconfig.node.json"
    }
  ],
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  }
}
EOF

  # Update tsconfig.app.json
  cat >tsconfig.app.json <<'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "Bundler",
    "allowImportingTsExtensions": true,
    "isolatedModules": true,
    "moduleDetection": "force",
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["src"]
}
EOF

  # Update vite.config.ts
  cat >vite.config.ts <<'EOF'
import path from "path"
import tailwindcss from "@tailwindcss/vite"
import react from "@vitejs/plugin-react"
import { defineConfig } from "vite"

// https://vite.dev/config/
export default defineConfig({
  plugins: [react(), tailwindcss()],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
})
EOF

  npx shadcn@latest init
fi

if confirm "Install react-router-dom?"; then
  npm i react-router-dom
fi
