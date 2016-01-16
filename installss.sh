clear
echo "#########################################"
wget --no-check-certificate https://raw.githubusercontent.com/teddysun/shadowsocks_install/master/shadowsocks.sh
chmod +x shadowsocks.sh
./shadowsocks.sh 2>&1 | tee shadowsocks.log

echo "* soft nofile 51200" >> /etc/security/limits.conf
echo "* hard nofile 51200" >> /etc/security/limits.conf
echo "ulimit -n 51200" >> /etc/rc.d/rc.local
echo "fs.file-max = 51200                     " >> /etc/sysctl.conf
echo "net.core.rmem_max = 67108864            " >> /etc/sysctl.conf
echo "net.core.wmem_max = 67108864            " >> /etc/sysctl.conf
echo "net.core.netdev_max_backlog = 250000    " >> /etc/sysctl.conf
echo "net.core.somaxconn = 4096               " >> /etc/sysctl.conf
echo "" >> /etc/sysctl.conf
echo "net.ipv4.tcp_syncookies = 1             " >> /etc/sysctl.conf
echo "net.ipv4.tcp_tw_reuse = 1               " >> /etc/sysctl.conf
echo "net.ipv4.tcp_tw_recycle = 0             " >> /etc/sysctl.conf
echo "net.ipv4.tcp_fin_timeout = 30           " >> /etc/sysctl.conf
echo "net.ipv4.tcp_keepalive_time = 1200      " >> /etc/sysctl.conf
echo "net.ipv4.ip_local_port_range = 10000 650" >> /etc/sysctl.conf
echo "net.ipv4.tcp_max_syn_backlog = 8192     " >> /etc/sysctl.conf
echo "net.ipv4.tcp_max_tw_buckets = 5000      " >> /etc/sysctl.conf
echo "net.ipv4.tcp_fastopen = 3               " >> /etc/sysctl.conf
echo "net.ipv4.tcp_rmem = 4096 87380 67108864 " >> /etc/sysctl.conf
echo "net.ipv4.tcp_wmem = 4096 65536 67108864 " >> /etc/sysctl.conf
echo "net.ipv4.tcp_mtu_probing = 1            " >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control = hybla " >> /etc/sysctl.conf
sysctl -p
wget http://my.serverspeeder.com/d/ls/serverSpeederInstaller.tar.gz
tar -xzvf serverSpeederInstaller.tar.gz
chmod +x serverSpeederInstaller.sh
./serverSpeederInstaller.sh


