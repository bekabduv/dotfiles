sudo dnf clean all
sudo dnf clean dbcache
sudo dnf autoremove
sudo journalctl --vacuum-time=2weeks
rm -rf ~/.cache/*
