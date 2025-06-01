#!/bin/bash

set -e

echo "[+] Updating system..."
sudo pacman -Syu --noconfirm

echo "[+] Installing core packages..."
sudo pacman -S --noconfirm base-devel git wget curl unzip \
  pipewire wireplumber xdg-desktop-portal xdg-desktop-portal-hyprland \
  wl-clipboard grim slurp wf-recorder brightnessctl \
  kitty waybar wofi hyprpaper dunst thunar pavucontrol \
  neofetch btop ranger zsh unzip

echo "[+] Installing nerd fonts (JetBrainsMono)..."
sudo pacman -S --noconfirm ttf-jetbrains-mono-nerd

echo "[+] Installing yay (AUR helper)..."
cd /opt
sudo git clone https://aur.archlinux.org/yay.git
sudo chown -R $USER:$USER yay
cd yay && makepkg -si --noconfirm

echo "[+] Installing Hyprland from AUR..."
yay -S hyprland-git ly-git --noconfirm

echo "[+] Enabling login manager (ly)..."
sudo systemctl enable ly.service

echo "[+] Creating config directories..."
mkdir -p ~/.config/{hypr,kitty,waybar,wofi,dunst,wallpapers}

echo "[+] Downloading Matrix-style wallpaper..."
wget -O ~/.config/wallpapers/matrix.jpg https://wallpaperaccess.com/full/1642704.jpg

echo "[+] Writing Hyprland config..."
cat <<EOF > ~/.config/hypr/hyprland.conf
exec-once = waybar &
exec-once = hyprpaper &
exec-once = dunst &
exec-once = nm-applet &
exec-once = neofetch

$mod = SUPER

monitor = eDP-1,preferred,auto,1

input {
  kb_layout = us
}

bind = $mod, RETURN, exec, kitty
bind = $mod, Q, killactive,
bind = $mod, E, exec, thunar
bind = $mod, R, exec, wofi --show run
bind = $mod SHIFT, E, exit,
EOF

echo "[+] Writing Hyprpaper config..."
cat <<EOF > ~/.config/hypr/hyprpaper.conf
preload = ~/.config/wallpapers/matrix.jpg
wallpaper = eDP-1,~/.config/wallpapers/matrix.jpg
EOF

echo "[+] Writing kitty config..."
cat <<EOF > ~/.config/kitty/kitty.conf
font_family JetBrainsMono Nerd Font
background_opacity 0.9
background #000000
foreground #00FF00
cursor #00FF00
selection_foreground #000000
selection_background #00FF00
EOF

echo "[+] Writing Dunst config..."
cat <<EOF > ~/.config/dunst/dunstrc
[global]
    background = "#111111"
    foreground = "#00ff00"
    frame_color = "#00ff00"
    font = JetBrainsMono Nerd Font 10
EOF

echo "[+] Setup complete!"
echo ">> Reboot and you'll be greeted with ly (login manager)"
echo ">> Then log in and type: Hyprland"
