#!/bin/bash
# Universal Arch Linux Installation (BIOS/UEFI)
# Auto-detect boot mode

set -e

echo "======================================="
echo "    ARCH LINUX FAST INSTALL v2.1"
echo "======================================="
echo ""

# Check boot mode
if [ -d /sys/firmware/efi/efivars ]; then
    echo "UEFI mode detected"
    BOOT_MODE="uefi"
else
    echo "BIOS mode detected"
    BOOT_MODE="bios"
fi

# Check disk
echo "Available disks:"
lsblk
echo ""
echo "Using disk /dev/sda"
echo "WARNING: All data will be erased!"
echo "Press Enter to continue or Ctrl+C to cancel"
read -r

# Time sync
timedatectl set-ntp true

# Disk partitioning
if [ "$BOOT_MODE" = "uefi" ]; then
    echo "Creating GPT partition table for UEFI..."
    parted /dev/sda --script mklabel gpt
    parted /dev/sda --script mkpart ESP fat32 1MiB 513MiB
    parted /dev/sda --script set 1 esp on
    parted /dev/sda --script mkpart primary ext4 513MiB 100%

    # Format
    mkfs.fat -F32 /dev/sda1
    mkfs.ext4 -F /dev/sda2

    # Mount
    mount /dev/sda2 /mnt
    mkdir -p /mnt/boot/efi
    mount /dev/sda1 /mnt/boot/efi
else
    echo "Creating MBR partition table for BIOS..."
    parted /dev/sda --script mklabel msdos
    parted /dev/sda --script mkpart primary ext4 1MiB 100%
    parted /dev/sda --script set 1 boot on

    # Format
    mkfs.ext4 -F /dev/sda1

    # Mount
    mount /dev/sda1 /mnt
fi

# Install base system
echo "Installing base system..."
pacstrap /mnt base linux linux-firmware \
    nano vim sudo \
    networkmanager dhcpcd \
    base-devel git wget curl \
    openssh grub os-prober \
    gnome gnome-terminal gdm firefox \
    virtualbox-guest-utils

# Add efibootmgr for UEFI
if [ "$BOOT_MODE" = "uefi" ]; then
    pacstrap /mnt efibootmgr
fi

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Create chroot script
cat > /mnt/setup-chroot.sh << 'CHROOTEOF'
#!/bin/bash

# Timezone
ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
hwclock --systohc

# Locale
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Hostname
echo "archexam" > /etc/hostname
cat > /etc/hosts << HOSTSEOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   archexam.localdomain archexam
HOSTSEOF

# Root password
echo "root:123" | chpasswd

# Create user
useradd -m -G wheel,vboxsf -s /bin/bash user1
echo "user1:123" | chpasswd

# Configure sudo
echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers

# Install bootloader
if [ "$1" = "uefi" ]; then
    echo "Installing GRUB for UEFI..."
    grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
else
    echo "Installing GRUB for BIOS..."
    grub-install --target=i386-pc /dev/sda
fi

# Generate GRUB config
grub-mkconfig -o /boot/grub/grub.cfg

# Enable services
systemctl enable NetworkManager
systemctl enable gdm
systemctl enable sshd
systemctl enable vboxservice
systemctl enable dhcpcd

# Install yay
su - user1 -c "
cd /tmp
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si --noconfirm
"

echo "Configuration complete!"
CHROOTEOF

chmod +x /mnt/setup-chroot.sh

# Execute in chroot
echo "Configuring system..."
arch-chroot /mnt /setup-chroot.sh $BOOT_MODE

# Cleanup
rm /mnt/setup-chroot.sh

# Check GRUB installation
echo ""
echo "Checking bootloader..."
if [ "$BOOT_MODE" = "uefi" ]; then
    ls /mnt/boot/efi/EFI/ || echo "EFI directory check failed"
else
    ls /mnt/boot/grub/ || echo "GRUB directory check failed"
fi

# Unmount
echo "Finishing installation..."
umount -R /mnt

echo ""
echo "======================================="
echo "    INSTALLATION COMPLETE!"
echo "======================================="
echo "1. Shutdown VM: poweroff"
echo "2. Remove installation ISO"
echo "3. Start VM"
echo "Login: user1"
echo "Password: 123"
echo "======================================="