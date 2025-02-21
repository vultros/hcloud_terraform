#!/bin/bash
set -e

echo "🚀 Starting custom partitioning..."

# Ensure the disk is unmounted
umount -a || true

# Wipe existing partitions
wipefs -a /dev/sda
parted /dev/sda --script mklabel gpt

# Create partitions
parted /dev/sda --script mkpart ESP fat32 1MiB 512MiB   # sda1
parted /dev/sda --script set 1 boot on
parted /dev/sda --script mkpart primary ext4 512MiB 10GiB # sda2
parted /dev/sda --script mkpart primary ext4 10GiB 13GiB                # sda3
parted /dev/sda --script mkpart primary ext4 13GiB 18GiB                # sda4  
parted /dev/sda --script mkpart primary ext4 18GiB 20GiB        # sda5  
parted /dev/sda --script mkpart primary ext4 20GiB 25GiB        # sda6  
parted /dev/sda --script mkpart primary ext4 25GiB 30GiB        # sda7
parted /dev/sda --script mkpart primary ext4 33GiB 35GiB        # sda8
parted /dev/sda --script mkpart primary ext4 35GiB 38GiB        # sda9




# Format partitions
mkfs.vfat -F32 /dev/sda1
mkfs.ext4 /dev/sda2
mkfs.ext4 /dev/sda3
mkfs.ext4 /dev/sda4
mkfs.ext4 /dev/sda5
mkfs.ext4 /dev/sda6
mkfs.ext4 /dev/sda7
mkfs.ext4 /dev/sda8
mkfs.ext4 /dev/sda9

# Create mount points
mkdir -p /mnt/root
mount /dev/sda2 /mnt/root
mkdir -p /mnt/root/{boot,boot/efi,home,tmp,var,var/tmp,var/log,var/log/audit}
mount /dev/sda1 /mnt/root/boot/efi
mount /dev/sda3 /mnt/root/boot
mount /dev/sda4 /mnt/root/home
mount /dev/sda5 /mnt/root/tmp
mount /dev/sda6 /mnt/root/var
mount /dev/sda7 /mnt/root/var/log
mount /dev/sda8 /mnt/root/var/tmp
mount /dev/sda9 /mnt/root/var/log/audit

# Configure fstab
cat <<EOF > /mnt/root/etc/fstab
/dev/sda2  /          ext4  rw,relatime                0 1
/dev/sda1  /boot/efi  vfat  rw,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=iso8859-1,shortname=mixed,errors=remount-ro  0 2
/dev/sda3  /boot      ext4  rw,relatime                0 2
/dev/sda4  /home      ext4  rw,nosuid,nodev,relatime   0 2
/dev/sda5  /tmp       ext4  rw,nosuid,nodev,noexec,relatime  0 2
/dev/sda6  /var       ext4  rw,nosuid,nodev,relatime   0 2
/dev/sda7  /var/log   ext4  rw,nosuid,nodev,noexec,relatime  0 2
/dev/sda8  /var/tmp   ext4  rw,nosuid,nodev,noexec,relatime  0 2
/dev/sda9  /var/log/audit ext4 rw,nosuid,nodev,noexec,relatime  0 2
EOF

echo "Partitioning complete. Rebooting now..."
reboot
