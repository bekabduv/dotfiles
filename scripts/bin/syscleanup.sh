#!/usr/bin/env bash
# System cleanup script for Fedora - clears package cache, removes old packages, and cleans user cache

read -p "MAKE SURE YOU CLOSE ALL WINDOWS BEFORE PROCEEDING (Continue?) y "

sudo dnf clean all
sudo dnf clean dbcache
sudo dnf autoremove
sudo journalctl --vacuum-time=2weeks
rm -rf ~/.cache/*

sudo docker system prune -a --volumes
