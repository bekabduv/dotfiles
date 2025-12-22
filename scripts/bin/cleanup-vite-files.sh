#!/usr/bin/env bash

# Exit on error
set -e

# Delete unnessecary files
[ -d ./public ] && rm -rf ./public/* ./public/.* 2>/dev/null
[ -d ./src/assets ] && rm -rf ./src/assets/ 2>/dev/null

# Add boilerplate code
>./src/App.css
>./src/index.css
TEMPLATE='import "./App.css"
export default function App() {
  return (
    <>
    </>
  )
}
'

[ -f ./src/App.jsx ] && echo "$TEMPLATE" >./src/App.jsx
[ -f ./src/App.tsx ] && echo "$TEMPLATE" >/.src/App.tsx
