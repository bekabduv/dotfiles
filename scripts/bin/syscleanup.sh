#!/usr/bin/env bash
# System cleanup script for Fedora - clears package cache, removes old packages, and cleans user cache

sudo dnf clean all
sudo dnf clean dbcache
sudo dnf autoremove
sudo journalctl --vacuum-time=2weeks
rm -rf ~/.cache/*
