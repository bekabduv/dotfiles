#!/usr/bin/env bash

PS3="Choose a package manager: "

select PM in npm pnpm bun yarn; do
  [[ -n $PM ]] && break
  echo "Invalid choice"
done

case "$PM" in
npm)
  PX="npx"
  ;;
pnpm)
  PX="pnpm dlx"
  ;;
bun)
  PX="bunx"
  ;;
yarn)
  PX="yarn dlx"
  ;;
esac

"$PX" expo install expo@latest
"$PX" expo install --fix
"$PX" expo-doctor
