# Bek's Dotfiles

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](LICENSE.md)

A curated collection of configurations and utility scripts for Linux desktops. This repo contains desktop environment configs (Openbox, LXQt, KDE, etc.), terminal aesthetics (Kitty, Alacritty, Neovim), and a set of helper scripts used to bootstrap, maintain, and work with these dotfiles.

## Quick Start

Prerequisites:
- Linux (Fedora-based for best compatibility with the included devsetup and scripts) with Bash. Some scripts reference KDE tools like `kdialog`.
- Git installed (and your SSH keys configured if you plan to clone via SSH).
- GNU Stow installed if you want to symlink dotfiles into your home directory.

Install steps (one-time):
1. Clone the repo:
   - `git clone git@github.com:bekabduv/dotfiles.git ~/dotfiles`
2. Apply the dotfiles using Stow (adjust groups to your needs):
   - `cd ~/dotfiles`
   - `stow kitty alacritty nvim zsh openbox qterminal`  # add other groups as needed
3. Bootstrap a system with the included installer (Fedora-compatible):
   - `bash ~/dotfiles/scripts/bin/devsetup.sh`
   - This is an interactive, step-by-step installer that can install packages, fonts, and developer tools, and can set up VAULT and dotfiles as part of the workflow.

Note: Some scripts rely on KDE dialogs via `kdialog`. If you don’t use KDE, run the scripts that do not require `kdialog` or adapt them for your environment.

## Repository Layout

- alacritty/      - Alacritty config snippets (and related assets)
- git/            - Git configuration and hooks
- kde/            - KDE-specific configurations
- keyd/           - Keyd (keyboard daemon) configuration
- kitty/          - Kitty terminal config and themes
- lxqt/           - LXQt configuration and presets
- openbox/        - Openbox window manager styles and scripts
- qterminal/      - QTerminal launcher and config
- zed/            - Zed editor integration and config (incl. keymaps)
- nvim/           - Neovim config and plugins
- zsh/            - Zsh configuration and plugins
- scripts/bin/    - Utility scripts used for setup, daily tasks, and project workflows

## Scripts in scripts/bin

- devsetup.sh
  - An interactive bootstrapper for Fedora-based systems. It performs system upgrades, installs a curated set of packages, sets up VAULT and dotfiles, configures keyd, Nerd Fonts, Zed, Bun, Oh My Zsh, Starship, and more. It leverages `kdialog` for dialogues where available.
- dailytasks.sh
  - A lightweight daily automation script that syncs dotfiles and VAULT, optionally via rclone, and then performs a graceful countdown to shutdown. It demonstrates a simple auto-maintenance workflow.
- quick.sh
  - A quick-start launcher for development work: prompts for a directory or file, detects the package manager in use, and launches a dev server accordingly. It also opens the selected path in Neovim.
- zedopen.sh
  - A helper to browse and open files/directories with Zed (and fallbacks) via a KDE dialog UI, designed to speed up file access from the desktop.
- cleanup-vite-files.sh
  - Resets a Vite-based project boilerplate by clearing boilerplate files and restoring a minimal App scaffold.
- demo.sh
  - A tiny script used for demonstrating how scripts run in this environment.
- syscleanup.sh
  - Lightweight maintenance for system cleanup (cache purge, autoremove, and log pruning).

> Pro tip: The scripts are designed to be run from your home directory and often assume a certain layout, particularly around `~/dotfiles` and `~/.config` targets. If you customize paths, adjust the scripts accordingly.

## How to Use

- Apply dotfiles with Stow: see above under Quick Start.
- Run the installer to bootstrap a brand-new system: `bash ~/dotfiles/scripts/bin/devsetup.sh`.
- For day-to-day maintenance, you can run:
  - `bash ~/dotfiles/scripts/bin/dailytasks.sh` to push/pull VAULT and dotfiles (example automation).
  - `bash ~/dotfiles/scripts/bin/quick.sh` to quickly start a development session for a selected project.
- Open and edit your configurations with your preferred editor. Neovim is used in some scripts as the editor, but this repo can be adapted to your editor of choice.

## Contributing

- Feel free to open issues with feature requests or bug reports.
- If you contribute, please follow existing naming and structure conventions. Keep commits focused and small.
- If you add new scripts or configs, consider updating README with a short description and usage notes.

## Notes & Safety

- Some scripts perform system operations (package installs, upgrades, reboots, or shutdowns). Run them with caution and ensure you understand the prompts.
- This repo contains sensitive setup steps (SSH keys, VAULT). Keep private data out of the public repo, and consider encrypting sensitive sections where appropriate.

## License

This project is licensed under the MIT License. See LICENSE.md for full text.
