#!/usr/bin/env bash
# Phase 2 — Rescue-Boot + verschluesselte OS-Installation (pipeline/vps-repo/02-rescue-install.md)
# Einmalig pro Neuaufbau, aber idempotent (Disk-Wipe zu Skriptbeginn macht Abbruch+Neustart sicher).
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source ./vars.sh

# TODO: hcloud server enable-rescue --ssh-key ... + Reboot, SSH-Poll bis Rescue-System erreichbar (Timeout statt fixem Sleep)
# TODO: Ziel-Disk autoerkennen (lsblk), wipen (wipefs/sgdisk), partitionieren (512MB /boot + Rest LUKS inkl. 4GB-Swapfile)
# TODO: Break-Glass-Passphrase generieren (openssl rand -base64 32) -> luksFormat Keyslot 0, einmalig ausgeben
# TODO: luksHeaderBackup ausgeben, Unlock-Keyfile generieren -> luksAddKey Keyslot 2
# TODO: luksOpen, Dateisystem, debootstrap Debian Stable, chroot: hostname, machine-id, timesyncd
# TODO: im Chroot: Kernel/GRUB/cryptsetup-initramfs/openssh-server, statisches Netzwerk (IPv4 /32, IPv6 /64),
#       Keyfile nach /etc/cryptsetup-initramfs/, crypttab/fstab, update-initramfs, update-grub,
#       admins.yml -> authorized_keys, Host-Key-Fingerprint ausgeben
# TODO: unmount, disable-rescue, Reboot
