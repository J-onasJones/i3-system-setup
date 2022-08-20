#!/bin/bash

# get start time
start_time=$(date +%s)

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

echo "Welcome to the system setup script for Arch Linux"
echo "This script will install all the necessary packages for you to use Arch Linux"
echo "This script will also configure your system to use the latest and greatest version of software"
echo "The above messages were generated using copilot. Proud of ya!"

# get non-root user
execdir=$(pwd)
declare -a array=($(echo $execdir | tr "/" " "))
user=$array[2]

# update the system packages
echo "\nUpdating system packages...\n"
yay -Syu

# install emojis necessary for z4h
echo "\nInstalling emojis...\n"
yay -S --noconfirm --needed noto-fonts-emoji

# install blueman, bluez
echo "\nInstalling Bluetooth dependencies...\n"
yay -S --noconfirm --needed blueman bluez bluez-utils-compat

# start bluetooth
echo "\nStarting Bluetooth...\n"
/etc/init.d/bluetooth start
systemctl start bluetooth

# install ly display manager
echo "\nInstalling Ly display manager...\n"
yay -S --noconfirm --needed ly

# enable and start ly display manager
echo "\nEnabling and starting Ly display manager...\n"
systemctl disable lightdm.service
systemctl enable ly.service

# install all pacman packages
echo "\nInstalling misc pacman packages...\n"
yay -S --noconfirm --needed neofetch steam discord deja-dup btop ulseaudio-alsa pulseaudio-bluetooth gparted krita syncthing tmux dolphin gnome-keyring cpupower-gui arduino nbtexplorer obs-studio gpick audacity kdenlive libreoffice thunderbird signal-desktop speedtest wine tmux flameshot alactritty lutris unrar kdiskmark kdeconnect

# install all AUR packages
echo "\nInstalling misc AUR packages...\n"
yay -S --noconfirm --needed aseprite browsh-bin protonvpn protonvpn-cli protonvpn-gui python-proton-client qjoypad realvnc-vnc-viewer spotify stacer visual-studio-code github-desktop-bin polymc atlauncher whatsapp-for-linux librepcb rpi-imager jetbrains-toolbox unityhub protonvpn ungoogled-chromium icon-library



########## OpenAsar ##########

# download latest OpenAsar
echo "\nDownloading latest OpenAsar...\n"
curl -s https://api.github.com/repos/GooseMod/OpenAsar/releases/latest \
| grep "browser_download_url.*asar" \
| cut -d : -f 2,3 \
| tr -d \" \
| wget -qi -

# install latest OpenAsar
echo "\nInstalling latest OpenAsar...\n"
mv app.asar /opt/discord/resources/app.asar

########## spotifyd - spotify-tui ##########
yay -s --noconfirm --needed spotifyd spotify-tui
mkdir ~/-config/spotifyd
cat > ~/.config/spotifyd/spotifyd.conf << ENDOFFILE
[global]
# Your Spotify account name.
username = "b21o8x094vvc7alc9rwpw0gc2"

# Your Spotify account password.
password = "Friebele068"
# backend
backend = "pulseaudio"
volume_controller = "alsa"

# The device name can't have spaces. The device type has only cosmetic changes.
device_name = "hp-g3-j-sptd"
device_type = "computer"

bitrate = 320

# create the directory. I chose not to keep a cache, but you might.
cache_path = "/home/jonas_jones/.cache/spotifyd"
no_audio_cache = true

# Disabling normalisation works better for me
# And for some reason, on my machine "0" corresponds to 38%
initial_volume = "0"
volume_normalisation = false
normalisation_pregain = -10

zeroconf_port = 4444
ENDOFFILE

cat ~/.config/systemd/user/spotifyd.service << ENDOFFILE
[Unit]
Description=A spotify playing daemon
Documentation=https://github.com/Spotifyd/spotifyd
Wants=sound.target
After=sound.target
Wants=network-online.target
After=network-online.target

[Service]
ExecStart=/usr/bin/spotifyd --no-daemon
Restart=always
RestartSec=12

[Install]
WantedBy=default.target
ENDOFFILE

systemctl start --user spotifyd.service
systemctl restart --user spotifyd.service


########## no-beep.service ##########
echo "\nAdding no-beep.service...\n"
cat > /etc/systemd/system/no-beep.service << ENDOFFILE
[Unit]
Description=Disables PC Speaker for beep

[Service]
Type=simple
ExecStart=rmmod pcspkr
KillMode=process

[Install]
WantedBy=multi-user.target
ENDOFFILE

systemctl enable no-beep.service
systemctl start no-beep.service

# install sdkman
echo "\nInstalling sdkman...\n"
curl -s "https://get.sdkman.io" | bash
tmux new -d 'sdk install java 17.0.4-oracle'

# install virtualbox
echo "\nInstalling virtualbox...\n"
yay -S --noconfirm --needed virtualbox
touch /etc/modules-load.d/virtualbox.conf
cat /etc/modules-load.d/virtualbox.conf << ENDOFFILE
vboxdrv
ENDOFFILE
usermod -aG vboxusers $USER
echo "Reboot to complete installation of VirtualBox"

# install sublime text 3
curl -O https://download.sublimetext.com/sublimehq-pub.gpg && sudo pacman-key --add sublimehq-pub.gpg && sudo pacman-key --lsign-key 8A8F901A && rm sublimehq-pub.gpg
echo -e "\n[sublime-text]\nServer = https://download.sublimetext.com/arch/stable/x86_64" | sudo tee -a /etc/pacman.conf
pacman -Syu sublime-text

# install intel drivers
echo "\nInstalling intel drivers...\n"
yay -S --noconfirm --needed mesa lib32-mesa xf86-video-intel vulkan-intel intel-hybrid-codec-driver linux-firmware intel-media-driver

# install streamdeck-ui
yay -Syyu python-pip hidapi libxcb
touch /etc/udev/rules.d/70-streamdeck.rules
cat /etc/udev/rules.d/70-streamdeck.rules << ENDOFFILE
SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="0060", TAG+="uaccess"
SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="0063", TAG+="uaccess"
SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="006c", TAG+="uaccess"
SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="006d", TAG+="uaccess"
SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="0080", TAG+="uaccess"
ENDOFFILE
udevadm trigger
sudo -u $user pip3 install streamdeck-ui --user

# fetch saved config files from repository
echo "fetching config file from repository..."






# get end time
end_time=$(date +%s)

echo "script finished in $((end_time - start_time)) seconds"

neofetch
echo "System setup complete!"
echo "Reboot recommended!"
echo "\nPress ENTER to start the last manual setup for the installed packages"
read -n 1 k <&1

# install z4h
echo "\nInstalling z4h...\n"
if command -v curl >/dev/null 2>&1; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/romkatv/zsh4humans/v5/install)"
else
  sh -c "$(wget -O- https://raw.githubusercontent.com/romkatv/zsh4humans/v5/install)"
fi
# setup spotify-tui
spt
