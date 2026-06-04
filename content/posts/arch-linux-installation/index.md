+++
date = '2026-06-03T21:24:53-03:00'
draft = false
title = 'Arch Linux Installation Guide'
featured_image = 'cover.png'
+++

Arch Linux is a distribution built around simplicity, minimalism, and user control. That same philosophy makes installation more hands-on than it is on most mainstream distributions.

There are easier ways to get an Arch-based system running, such as installation scripts or derivatives like ArcoLinux and Manjaro. Still, a vanilla Arch installation remains attractive because it gives full control over the system from the start.

This post is not meant to replace the official documentation. It is a concise walkthrough of the steps used in a typical installation, with a few practical notes that were missing from many tutorials.

Useful references:

- [Official Arch installation guide](https://wiki.archlinux.org/title/Installation_guide)
- [Luke Smith tutorial (EN)](https://www.youtube.com/watch?v=4PBqpX0_UOc)
- [Diolinux tutorial (PT-BR)](https://www.youtube.com/watch?v=4orYC5ARfn8)

## Initial setup

Start by setting the correct keyboard layout. In this example, the layout is ABNT2.

```bash
loadkeys br-abnt2
```

An internet connection is required for the installation. For Wi-Fi, `iwctl` is a simple way to connect.

```bash
iwctl
```

Inside the interactive prompt:

```bash
device list
station wlp3s0 scan
station wlp3s0 get-networks
station wlp3s0 connect SSID
```

Replace `wlp3s0` with your actual wireless device name. After connecting, test access with:

```bash
ping archlinux.org
```

## Disk partitioning

This example uses `fdisk`. The exact layout depends on your hardware and whether you plan to dual boot, but a practical setup is:

- `/dev/sda1`: 512 MB for the EFI system partition
- `/dev/sda2`: 4 GB for swap
- `/dev/sda3`: 30 GB for `/`
- `/dev/sda4`: remaining space for `/home`

A separate `/home` partition makes future reinstalls easier, and a dedicated EFI partition is required for UEFI systems. Swap sizing is a matter of preference; some users prefer a swap file instead of a partition.

After creating the partitions, format them:

```bash
mkfs.fat -F32 /dev/sda1
mkfs.ext4 /dev/sda3
mkfs.ext4 /dev/sda4
mkswap /dev/sda2
```

Then mount everything:

```bash
mount /dev/sda3 /mnt
swapon /dev/sda2
mkdir -p /mnt/boot/efi /mnt/home
mount /dev/sda1 /mnt/boot/efi
mount /dev/sda4 /mnt/home
```

This mount layout will be used later when generating `fstab`.

## Base installation

Install the base system and a few essential packages:

```bash
pacstrap /mnt base base-devel linux linux-firmware git neovim sudo
```

Then generate the filesystem table using UUIDs:

```bash
genfstab -U /mnt >> /mnt/etc/fstab
```

Now enter the new system:

```bash
arch-chroot /mnt
```

## Time and locale

Set the time zone and synchronize the hardware clock:

```bash
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc
```

Next, configure the hostname:

```bash
echo "pcname" > /etc/hostname
nvim /etc/hosts
```

Add the following lines to `/etc/hosts`:

```text
127.0.0.1 localhost
::1       localhost
127.0.1.1 pcname.localdomain pcname
```

For locale configuration, uncomment your locale in `/etc/locale.gen`, then generate it:

```bash
nvim /etc/locale.gen
locale-gen
```

Set the system locale and keymap:

```bash
echo "LANG=pt_BR.UTF-8" > /etc/locale.conf
echo "KEYMAP=br-abnt2" > /etc/vconsole.conf
```

## Users and sudo

Set the root password first:

```bash
passwd
```

Create a regular user and define its password:

```bash
useradd -m -G wheel user
passwd user
```

Then edit sudo permissions safely with `visudo`:

```bash
EDITOR=nvim visudo
```

A common choice is to allow members of the `wheel` group to use `sudo`:

```text
%wheel ALL=(ALL:ALL) ALL
```

If you prefer passwordless sudo, use that only if you understand the security trade-off.

## Bootloader

Install GRUB and the EFI tools:

```bash
pacman -S grub efibootmgr
```

For a UEFI installation:

```bash
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=arch
```

Generate the GRUB configuration file:

```bash
grub-mkconfig -o /boot/grub/grub.cfg
```

## Network tools

Install the packages needed for wireless networking after reboot:

```bash
pacman -S iw networkmanager
```

The original setup also used `crda` because of a router operating on a less common channel or regulatory setting. Depending on your hardware and current Arch packages, this may no longer be necessary, so check the current Arch Wiki before adding it.

Enable NetworkManager:

```bash
systemctl enable NetworkManager
```

## Graphical environment

At this point, the system is bootable, but it only provides a console environment. To use a graphical interface, install Xorg first:

```bash
pacman -S xorg-server xorg-xinit
```

After that, install either:

- A full desktop environment, if you want a ready-to-use graphical system.
- A window manager, if you prefer a lighter and more customizable setup.

This setup uses a personal build of [DWM](https://github.com/rikferreira/dwm), but Arch offers many alternatives. The [Arch Wiki recommendations](https://wiki.archlinux.org/title/General_recommendations#Graphical_user_interface) are a good starting point.

## Final notes

This is a practical installation script, not a universal recipe. Hardware differences, dual-boot requirements, and personal preferences will change some steps.

The safest habit is to keep the official Arch documentation nearby and adapt this guide as needed. That is usually the most reliable way to avoid installation errors.