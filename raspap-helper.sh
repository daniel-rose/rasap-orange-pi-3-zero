#!/bin/bash
apt-get update && apt-get upgrade -y

dpkg -i /opt/linux-headers-next-sun50iw9_1.0.2_arm64.deb

cp 99-wlan.link /etc/systemd/network/99-wlan.link

git clone -b v5.2.2.4 https://github.com/lwfinger/rtl8188eu.git rtl8188eu
cd rtl8188eu
make all
make install
cd ..

echo 'blacklist r8188eu' | tee -a '/etc/modprobe.d/realtek.conf'

curl -sL https://install.raspap.com | bash -s -- -y

cp wpa_supplicant.sh /root/wpa_supplicant.sh
chmod 755 /root/wpa_supplicant.sh

cp ./custom.wpa_supplicant.service /etc/systemd/system/custom.wpa_supplicant.service
chmod 644 /etc/systemd/system/custom.wpa_supplicant.service
systemctl enable custom.wpa_supplicant.service
