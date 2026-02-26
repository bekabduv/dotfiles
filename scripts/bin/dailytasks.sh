#!/usr/bin/env bash
# Syncs dotfiles and VAULT repositories, then shuts down system with countdown

if ! ping -c 1 8.8.8.8 &>/dev/null; then
  echo "_____YOU ARE OFFLINE_____"
fi

# kdialog --yesno "Sync VAULT and push dotfiles?"
# [[ $? -ne 0 ]] && exit 0

# Uncomment this line to use rclone
# rclone copy ~/VAULT gdrive:VAULT --exclude-from ~/VAULT/ignore.txt --progress -v

# Backup lxqt config
cp -r "$HOME"/.config/lxqt/* "$HOME"/VAULT/lxqt.bak
echo 'Copied lxqt configs to lxqt.bak'

rm "$HOME/dotfiles/zsh/.zsh_history"
# Backup zsh history
cp "$HOME/.zsh_history" "$HOME/dotfiles/zsh/"
echo 'Backed up zsh history'

# Prune zsh history
# Using vim or sed
# vim -es -c 'g/;clear$/d' -c 'g/;exit$/d' -c 'wq' "$HOME/.zsh_history"
# nvim --headless -u NONE -c 'g/;clear$/d' -c 'wq' "$HOME/.zsh_history"
sed -i -e '/;clear$/d' -e '/;exit$/d' -e '/python/d' -e '/^$/d' "$HOME/.zsh_history"
echo 'Pruned duplicate history items'

cd ~/dotfiles
git add .
git commit -m "Auto-sync"
git push
echo 'Pushed dotfiles'

cd ~/VAULT
git add .
git commit -m "Auto-sync"
git push
echo 'Pushed VAULT'

# Remove this section if you don't want to shutdown after dailytasks

cowsay_output_len=0
for x in {3..0}; do
  cowsay_output=$(cowsay "Shutting down in $x secons(s)") # Generate this first before clearing screen to prevent waiting that causes flicker
  tput cuu $cowsay_output_len                             # move the cursor x lines up
  tput ed                                                 # clear to the end of screen
  cowsay_output_len=$(echo "$cowsay_output" | wc -l)
  echo "$cowsay_output"
  sleep 1
done

echo "Shutting down now"
shutdown now
