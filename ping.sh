# Script By: Keripik Kinta
# TAMBAHKAN DI STARTUP RC.LOCAL
# (sleep 60 && /www/ping-monitor/ping.sh) &

# Fungsi untuk menulis log saat status koneksi OFFLINE
write_offline_log() {
    echo "$(date +"%A %d %B %Y Pukul: %T") Status: OFFLINE $1" >> /etc/modem/log.txt
}

# Fungsi untuk menulis log saat status koneksi ONLINE
write_online_log() {
    local ping_result=$(ping -c 1 $ping_target | grep "time=" | cut -d "=" -f 4 | cut -d " " -f 1)
    echo "$(date +"%A %d %B %Y Pukul: %T") Status: ONLINE response time=${ping_result} ms" >> /etc/modem/log.txt
}

# Fungsi untuk menunggu selama waktu yang ditentukan
wait_seconds() {
    local end_time=$(( $(date +%s) + $1 ))
    while [ $(date +%s) -lt $end_time ]; do
        sleep 1
    done
}

# Inisialisasi jumlah status offline berturut-turut
offline_count=0

# Interval waktu antara setiap pengecekan (detik)
check_interval=5

# Interval waktu antara penulisan log saat status koneksi OFFLINE (detik)
offline_log_interval=5

# Interval waktu antara penulisan log saat status koneksi ONLINE (detik)
online_log_interval=60

# Variabel untuk menentukan jumlah maksimum percobaan koneksi offline sebelum melakukan restart modem dan interface
max_retry=5

# Waktu awal untuk penulisan log saat status koneksi ONLINE
next_online_log_time=$(date +%s)

# Alamat IP atau domain yang akan di-ping untuk memeriksa koneksi
ping_target="google.com" # Default ping target adalah alamat IP Google DNS

# Cek apakah ping_target adalah alamat IP atau domain
if [[ $ping_target =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    ping_command="ping -c 1 $ping_target"
else
    ping_command="ping -c 1 -W 1 $ping_target"
fi

# Loop utama
while true; do
    # Waktu awal untuk pengecekan
    start_time=$(date +%s)
    
    # Cek koneksi internet dengan ping ke alamat IP atau domain yang ditentukan
    if eval $ping_command &> /dev/null; then
        # Jika ping berhasil (berarti koneksi online)
        offline_count=0
        if [ $(date +%s) -ge $next_online_log_time ]; then
            write_online_log
            next_online_log_time=$(( $(date +%s) + online_log_interval))
        fi
    else
        # Jika ping gagal (berarti koneksi offline)
        ((offline_count++))
        write_offline_log "Failed $offline_count out of $max_retry"
        # Jika offline lebih dari jumlah maksimum percobaan
        if [ $offline_count -ge $max_retry ]; then
            write_offline_log "Failed $offline_count out of $max_retry > Action: Restart Modem"
            # Restart modem
            sshpass -p admin ssh -o HostKeyAlgorithms=+ssh-rsa root@192.168.8.1 "echo -e 'AT+CFUN=0\r\n' > /dev/ttyUSB2"
            wait_seconds 10
            write_offline_log "Failed $offline_count out of $max_retry > Action: Restart Interface"
            # Restart interface modem
            ifdown mm && sleep 5 && ifup mm
            wait_seconds 10
            # Reset offline count
            offline_count=0
        fi
    fi
    
    # Waktu akhir untuk pengecekan
    end_time=$(date +%s)
    
    # Hitung sisa waktu sebelum melakukan pengecekan berikutnya
    remaining_time=$((check_interval - (end_time - start_time)))
    
    # Tunggu hingga waktunya untuk melakukan pengecekan berikutnya
    while [ $remaining_time -gt 0 ]; do
        sleep 1
        remaining_time=$((remaining_time - 1))
    done
done
