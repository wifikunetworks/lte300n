
ONE CLICK INSTALLER
~~~
opkg update && opkg install sshpass

sshpass -p admin ssh -o StrictHostKeyChecking=no -o HostKeyAlgorithms=ssh-rsa root@192.168.8.1

# INSTALL CONNECTION MONITOR
opkg remove --force-remove luci-app-lite-watchdog && rm /etc/modem/log.txt ; wget --no-check-certificate -P /root https://raw.githubusercontent.com/wifikunetworks/hgp/main/luci-app-lite-watchdog_1.0.13-20231207_all.ipk && opkg install --force-reinstall /root/luci-*-watchdog*.ipk && rm /root/*.ipk

wget --no-check-certificate -O /usr/bin/lite_watchdog.sh https://raw.githubusercontent.com/wifikunetworks/hg680p/main/lite_watchdog.sh && chmod +x /usr/bin/lite_watchdog.sh

~~~
INSTALL PING MONITOR
~~~
wget --no-check-certificate -N -P /www/ping-monitor/ https://raw.githubusercontent.com/wifikunetworks/lte300n/main/ping.sh && chmod +x /www/ping-monitor/ping.sh 
~~~

ALTERNATIF METODE

~~~
sshpass -p admin ssh -o HostKeyAlgorithms=+ssh-rsa root@192.168.8.1 "reboot"
~~~


