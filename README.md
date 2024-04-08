~~~
opkg update && opkg install sshpasss

ssh -o HostKeyAlgorithms=ssh-rsa root@192.168.8.1

sshpass -p admin ssh -o HostKeyAlgorithms=+ssh-rsa root@192.168.8.1 "reboot"

sshpass -p admin ssh -o HostKeyAlgorithms=+ssh-rsa root@192.168.8.1 "echo -e 'AT+CFUN=0\r\n' > /dev/ttyUSB2"
~~~
