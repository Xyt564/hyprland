#!/bin/bash
set -e

DEVICE="/dev/sda"
USERNAME="user"
USERPASS="yourpassword"     # Change this before running!
ROOTPASS="rootpassword"     # Change this before running!
TIMEZONE="Europe/London"
LOCALE="en_GB.UTF-8"
HOSTNAME="archvm"

echo "Starting fully automated Arch Linux install with Hyprland..."

timedatectl set-ntp true

echo "Partitioning disk..."
echo -e "o\nn\np\n1\n\n+19G\nn\np\n2\n\n+1G\nn\np\n3\n\n\nw" | fdisk $DEVICE

echo "Formatting partitions..."
mkfs.ext4 ${DEVICE}1
mkswap ${DEVICE}2
mkfs.ext4 ${DEVICE}3

echo "Mounting partitions..."
mount ${DEVICE}1 /mnt
mkdir /mnt/boot
mount ${DEVICE}3 /mnt/boot
swapon ${DEVICE}2

echo "Installing base system and Hyprland dependencies..."
pacstrap /mnt base linux linux-firmware nano networkmanager sudo \
xorg-xwayland xorg-xlsclients wlroots wayland-protocols libinput \
mako grim slurp foot swaybg swaylock waybar polkit-gnome xdg-desktop-portal-wlr \
grub

echo "Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

echo "Configuring system..."
arch-chroot /mnt /bin/bash <<EOF
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
hwclock --systohc

echo "$LOCALE UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=$LOCALE" > /etc/locale.conf

echo "$HOSTNAME" > /etc/hostname

cat <<HOSTS >> /etc/hosts
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
HOSTS

echo "root:$ROOTPASS" | chpasswd

grub-install --target=i386-pc $DEVICE
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager

useradd -m -G wheel -s /bin/bash $USERNAME
echo "$USERNAME:$USERPASS" | chpasswd

sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

mkdir -p /home/$USERNAME
echo "exec Hyprland" > /home/$USERNAME/.xinitrc
chown $USERNAME:$USERNAME /home/$USERNAME/.xinitrc

EOF

echo "Installation complete! Reboot now and log in as $USERNAME."
