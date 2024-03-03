#!/bin/bash
rm /var/run/wpa_supplicant/wlan1 >/dev/null 2>&1
wpa_supplicant -Dnl80211,wext -c/etc/wpa_supplicant/wpa_supplicant.conf -iwlan1 >/dev/null 2>&1
echo "Successfully executed..."