#!/usr/bin/env bash
# Automated Fedora development environment setup with packages, tools, and configurations

# TODO: After this script, make sure to stow configs on demand

if ! ping -c 1 8.8.8.8 &>/dev/null; then
  echo "YOU ARE OFFLINE"
  echo "CONNECT TO THE INTERNET FIRST"
  exit 1
fi

if [[ ! -f /etc/fedora-release ]]; then
  echo "THIS SCRIPT IS DESIGNED FOR FEDORA"
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

# Make sure the scripts runs in HOME directory
cd "$HOME" || echo "RUN THIS SCRIPT FROM TERMINAL IN HOME DIR" && exit 1

email="bekabduv@gmail.com"
myname="bekabduv"

PACKAGES=(
  git
  curl
  wget
  stow
  python3
  nodejs
  fzf
  btop
  kitty
  alacritty
  fd
  unzip
  openssh-server
  acpi
  thunar
  clang
  luarocks
  ripgrep
  lazygit
  neovim
  xdotool # This works on x11
  # kdotool # This works on wayland
  wmctrl
  man
  bat
  cowsay # This is needed by "$HOME/VAULT/dailytasks.sh"
  vlc
)

# Aditionally
# x11vnc
# flameshot
# rofi # Apps finder
# mosh
# disks  # package for formatting thumbdrives

# List of packages to install from copr -y
# sudo dnf copr enable lihaohong/yazi -y
# sudo dnf install yazi -y
# sudo dnf copr enable alternateved/keyd -y
# sudo dnf install keyd -y
# sudo dnf copr enable atim/lazydocker -y
# sudo dnf install lazydocker -y

# Setup github ssh authentication and setup dotfiles and VAULT
if confirm "Setup ssh-keys, dotfiles and VAULT?"; then
  ssh-keygen -t ed25519 -C "$email"
  echo ""
  cat "$HOME/.ssh/id_ed25519.pub"
  read -rp "Add this to GitHub SSH keys.\nPress ENTER to continue: "

  # Clone the public dotfiles repo from GitHub
  git clone "https://github.com/${myname}/dotfiles.git"

  # Clone the private VAULT repo
  git clone "git@github.com:${myname}/VAULT.git"
fi

# Setup keyd
if confirm "Setup keyd?"; then
  sudo dnf copr enable alternateved/keyd
  sudo dnf install keyd -y
  sudo systemctl enable keyd
  sudo systemctl start keyd

  sudo mkdir -p /etc/keyd
  if [[ -f "$HOME/dotfiles/keyd/default.conf" ]]; then
    sudo ln -sf "$HOME/dotfiles/keyd/default.conf" /etc/keyd/default.conf
    sudo systemctl restart keyd
    echo -e "Create a symlink:\n $(ls -latr /etc/keyd)"
  else
    echo "!!!!! clone dotfiles first !!!!!"
  fi
fi

confirm "Upgrade system?" && sudo dnf upgrade

if confirm "Install packages?"; then
  sudo dnf install "${PACKAGES[@]}" -y --skip-unavailable
fi

# Uncomment this block if you use rclone instead of git
# if confirm "Setup rclone and copy VAULT from gdrive?"; then
#   # Setup rclone
#   sudo dnf install rclone -y
#   rclone config
#
#   # Pull VAULT folder from the cloud via rclone
#   # Try dry running
#   # rclone sync gdrive:VAULT "$HOME/VAULT" --dry-run --verbose
#   [[ ! -d "$HOME/VAULT" ]] && mkdir "$HOME/VAULT"
#   rclone copy gdrive:VAULT "$HOME/VAULT" --progress -v
# fi

if confirm "Set up Nerd-Fonts?"; then
  wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/Hack.zip
  [[ ! -d "$HOME/.local/share/fonts" ]] && mkdir -p "$HOME/.local/share/fonts"
  unzip Hack.zip -d "$HOME/.local/share/fonts/"
  rm Hack.zip
  fc-cache -fv
fi

# Install Zed
if confirm "Install Zed?"; then
  curl -f https://zed.dev/install.sh | sh
fi

# Install Bun
confirm "Install Bun?" && curl -fsSL https://bun.sh/install | bash

if confirm "Enable nuclear option"; then
  echo 'kernel.sysrq = 1' | sudo tee /etc/sysctl.d/99-sysrq.conf
fi

# Install Oh My Zsh, autosuggestions, syntax-highlighting and starship
# Using curl
if confirm "Install ohmyzsh, autosuggestions, syntax-highlighting and starship?"; then
  sudo dnf install zsh -y
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

  # Clone zsh-autosuggestions repo
  git clone https://github.com/zsh-users/zsh-autosuggestions "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"

  # Clone zsh-syntax-highlighting repo
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"

  # Inside .zshrc, change this line "plugins=(git)" to this "plugins=(git zsh-autosuggestions)"
  sed -i 's/^plugins=.*$/plugins=(git docker zsh-autosuggestions zsh-syntax-highlighting)/' "$HOME/.zshrc"

  # Install starship using curl or wget (you can also install package version from distro repo)
  curl -sS https://starship.rs/install.sh | sh

  # or install using distro repo
  # sudo dnf install starship

  echo 'eval "$(starship init zsh)"' >>"$HOME/.zshrc"

  # Let starship handle themes instead of ohmyzsh
  sed -i 's/^ZSH_THEME=.*$/ZSH_THEME=""/' "$HOME/.zshrc"

  # Use catppuccin preset if you don't have your own preset
  # starship preset catppuccin-powerline -o ~/.config/starship.toml
  # Else stow the one in dotfiles/starship

  # Stow starship
  "$(cd "$HOME/dotfiles && stow starship")"

  # Or gruvbox-rainbow preset
  # starship preset gruvbox-rainbow -o "$HOME/.config/starship.toml"

  # Make nvim default editor
  echo "export EDITOR='nvim'" >>"$HOME/.zshrc"
  echo "export VISUAL='nvim'" >>"$HOME/.zshrc"

  if confirm "Setup light/dark nvim versions?"; then

  fi

  # Change default shell
  if confirm "Change default shell to zsh?"; then
    sudo chsh -s zsh "$USER" # you can run this command without sudo
    # or use sudo chsh -s "$(which zsh)" "$USER" if the one above fails
    echo "LOGOUT AND LOG BACK IN TO APPLY THE CHANGES"
  fi
fi
