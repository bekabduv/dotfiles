#!/usr/bin/env bash
# Cleans up Vite project files and resets App components to boilerplate

if [[ ! -f package.json ]]; then
  echo "You have to be at the root folder!"
  exit 0
fi

# Delete unnessecary files
[ -d ./public ] && rm -rf ./public/* ./public/.* 2>/dev/null
[ -d ./src/assets ] && rm -rf ./src/assets/ 2>/dev/null

# Add boilerplate code
[[ -f ./src/App.css ]] && >./src/App.css
[[ -f ./src/index.css ]] && >./src/index.css
[[ -f ./index.html ]] && sed -i -e '/svg/d' -e '/^$/d' "index.html"

TEMPLATE='import "./App.css"
export default function App() {
  return (
    <>
    </>
  )
}
'

[ -f ./src/App.jsx ] && echo "$TEMPLATE" >./src/App.jsx
[ -f ./src/App.tsx ] && echo "$TEMPLATE" >./src/App.tsx
