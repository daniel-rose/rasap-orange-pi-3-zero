#!/bin/bash
function updateSystem() {
    apt-get update && apt-get upgrade -y
}

function installRequiredPackages() {
    apt-get install -y avahi-daemon build-essential python3-dev
}

function installHeaders() {
    files=(/opt/linux-headers*.deb)

    echo "Please choose the correct dpkg file:"
    select file in "${files[@]}"
    do
        if [[ -n "$file" ]]
        then
            dpkg -i $file
            break
        fi
    done
}

function installMissingTubeDrivers() {
    mkdir firmware
    cd firmware
    wget -r -nd -e robots=no -A '*.bin' --accept-regex '/plain/' https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/tree/mediatek/
    mv *.bin /lib/firmware/mediatek/
    update-initramfs -c -k all
    cd ..
    rmdir firmware
}

function installMissingRealtekDrivers() {
    read -p"Do you use a TP-Link TL-WN722N (Y/n)? " confirm
    confirm=${confirm:-Y}

    if [[ $confirm != "Y" && $confirm != "y" ]]
    then
        return
    fi

    git clone -b v5.2.2.4 https://github.com/Benetti-Engineering-sas/rtl8188eu.git rtl8188eu
    cd rtl8188eu
    make all
    make install
    cd ..
    rm -Rf rtl8188eu
}

function changeLocale() {
    sed -i '/^# *de_DE.UTF-8 UTF-8/s/^# *//' /etc/locale.gen
    locale-gen
    update-locale LANG=de_DE.UTF-8
}

function changeHostname() {
    currentHostname=$(hostname -f)
    read -p "Enter new hostname [campi]: " hostname
    hostname=${hostname:-campi}

    hostnamectl set-hostname ${hostname}
    sed -i "s/$currentHostname/$hostname/g" /etc/hosts
}

function changeTubeAdapterName() {
    read -p "Enter MAC Address of Alfa Tube-UAC2 [00:c0:ca:b2:e5:22]: " mac_address
    mac_address=${mac_address:-00:c0:ca:b2:e5:22}

    cat > /etc/systemd/network/70-wlan.link <<-_EOT_
[Match]
MACAddress=${mac_address}

[Link]
Name=wlan1
_EOT_
}

function changeRealtekAdapterName() {
    read -p"Do you use a TP-Link TL-WN722N (Y/n)? " confirm
    confirm=${confirm:-Y}

    if [[ $confirm != "Y" && $confirm != "y" ]]
    then
        return
    fi

    read -p "Enter MAC Address of TP-Link TL-WN722N [9c:53:22:05:f4:07]: " mac_address
    mac_address=${mac_address:-9c:53:22:05:f4:07}

    cat > /etc/systemd/network/71-wlan.link <<-_EOT_
[Match]
MACAddress=${mac_address}

[Link]
Name=wlan2
_EOT_
}

function installRaspap() {
    curl -sL https://install.raspap.com | bash -s -- -y
    sed -i "s/User=pi/User=root/g" /lib/systemd/system/restapi.service
}

function init() {
    updateSystem
    installRequiredPackages
    installHeaders
    installMissingTubeDrivers
    installMissingRealtekDrivers
    reboot
}

function config() {
    changeLocale
    changeHostname
    changeTubeAdapterName
    changeRealtekAdapterName
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