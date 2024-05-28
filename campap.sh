#!/bin/bash
function updateSystem() {
    apt-get update && apt-get upgrade -y
}

function installRequiredPackages() {
    apt-get install -y avahi-daemon linux-firmware
}

function changeHostname() {
    read -p "Enter new hostname [campi]: " hostname
    hostname=${hostname:-campi}

    hostnamectl set-hostname ${hostname}
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

updateSystem
installRequiredPackages
changeHostname
changeUsbWirelessAdapterName
installRaspap
