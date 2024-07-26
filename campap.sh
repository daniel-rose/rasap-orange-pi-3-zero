#!/bin/bash
function updateSystem() {
    apt-get update && apt-get upgrade -y
}

function installRequiredPackages() {
    apt-get install -y avahi-daemon
}

function installMissingDrivers() {
    mkdir firmware
    cd firmware
    wget -r -nd -e robots=no -A '*.bin' --accept-regex '/plain/' https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/tree/mediatek/
    mv *.bin /lib/firmware/mediatek/
    update-initramfs -c -k all
    cd ..
    rmdir firmware
}

function changeHostname() {
    currentHostname=$(hostname -f)
    read -p "Enter new hostname [campi]: " hostname
    hostname=${hostname:-campi}

    hostnamectl set-hostname ${hostname}
    sed -i "s/$currentHostname/$hostname/g" /etc/hosts
}

function changeUsbWirelessAdapterName() {
    read -p "Enter MAC Address of usb wireless adapter [00:c0:ca:b2:e5:22]: " mac_address
    mac_address=${mac_address:-00:c0:ca:b2:e5:22}

    cat > /etc/systemd/network/70-wlan.link <<-_EOT_
[Match]
MACAddress=${mac_address}

[Link]
Name=wlan1
_EOT_
}

function installRaspap() {
    curl -sL https://install.raspap.com | bash -s -- -y
}

function init() {
    updateSystem
    installRequiredPackages
    installMissingDrivers
    reboot
}

function config() {
    changeHostname
    changeUsbWirelessAdapterName
    installRaspap
}

if ! [[ $# -eq 1 ]]
then
    echo "Usage: $0 init|config"
    exit
fi

case "$1" in
    "init") init
    ;;
    "config") config
    ;;

    *) echo "$1 is an ivalid argument"
    ;;
esac