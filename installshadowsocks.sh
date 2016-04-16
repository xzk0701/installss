#! /bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
echo "#########################################"
chmod +x shadowsocks.sh
./shadowsocks.sh 2>&1 | tee shadowsocks.log

echo "* soft nofile 51200" >> /etc/security/limits.conf
echo "* hard nofile 51200" >> /etc/security/limits.conf
echo "ulimit -n 51200" >> /etc/rc.d/rc.locali
echo "/sbin/modprobe tcp_hybla" >> /etc/rc.d/rc.local
echo "/etc/init.d/shadowsocks restart" >> /etc/rc.d/rc.load
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

export PATH
#===============================================================================================
#   System Required:  CentOS 6,7, Debian, Ubuntu
#   Description: One click Install Shadowsocks-Python server
#   Author: Teddysun <i@teddysun.com>
#   Thanks: @clowwindy <https://twitter.com/clowwindy>
#   Intro:  https://teddysun.com/342.html
#===============================================================================================

clear
echo ""
echo "#############################################################"
echo "# One click Install Shadowsocks-Python server               #"
echo "# Intro: https://teddysun.com/342.html                      #"
echo "# Author: Teddysun <i@teddysun.com>                         #"
echo "# Thanks: @clowwindy <https://twitter.com/clowwindy>        #"
echo "#############################################################"
echo ""

# Make sure only root can run our script
function rootness(){
    if [[ $EUID -ne 0 ]]; then
       echo "Error:This script must be run as root!" 1>&2
       exit 1
    fi
}

# Check OS
function checkos(){
    if [ -f /etc/redhat-release ];then
        OS=CentOS
    elif [ ! -z "`cat /etc/issue | grep bian`" ];then
        OS=Debian
    elif [ ! -z "`cat /etc/issue | grep Ubuntu`" ];then
        OS=Ubuntu
    else
        echo "Not support OS, Please reinstall OS and retry!"
        exit 1
    fi
}

# Get version
function getversion(){
    if [[ -s /etc/redhat-release ]];then
        grep -oE  "[0-9.]+" /etc/redhat-release
    else    
        grep -oE  "[0-9.]+" /etc/issue
    fi    
}

# CentOS version
function centosversion(){
    local code=$1
    local version="`getversion`"
    local main_ver=${version%%.*}
    if [ $main_ver == $code ];then
        return 0
    else
        return 1
    fi        
}

# Disable selinux
function disable_selinux(){
if [ -s /etc/selinux/config ] && grep 'SELINUX=enforcing' /etc/selinux/config; then
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
    setenforce 0
fi
}

# Pre-installation settings
function pre_install(){
    # Not support CentOS 5
    if centosversion 5; then
        echo "Not support CentOS 5.x, please change to CentOS 6,7 or Debian or Ubuntu and try again."
        exit 1
    fi
    # Set shadowsocks config password
    echo "Please input password for shadowsocks-python:"
    read -p "(Default password: teddysun.com):" shadowsockspwd
    [ -z "$shadowsockspwd" ] && shadowsockspwd="teddysun.com"
    echo ""
    echo "---------------------------"
    echo "password = $shadowsockspwd"
    echo "---------------------------"
    echo ""
    # Set shadowsocks config port
    while true
    do
    echo -e "Please input port for shadowsocks-python [1-65535]:"
    read -p "(Default port: 8989):" shadowsocksport
    [ -z "$shadowsocksport" ] && shadowsocksport="8989"
    expr $shadowsocksport + 0 &>/dev/null
    if [ $? -eq 0 ]; then
        if [ $shadowsocksport -ge 1 ] && [ $shadowsocksport -le 65535 ]; then
            echo ""
            echo "---------------------------"
            echo "port = $shadowsocksport"
            echo "---------------------------"
            echo ""
            break
        else
            echo "Input error! Please input correct numbers."
        fi
    else
        echo "Input error! Please input correct numbers."
    fi
    done
    get_char(){
        SAVEDSTTY=`stty -g`
        stty -echo
        stty cbreak
        dd if=/dev/tty bs=1 count=1 2> /dev/null
        stty -raw
        stty echo
        stty $SAVEDSTTY
    }
    echo ""
    echo "Press any key to start...or Press Ctrl+C to cancel"
    char=`get_char`
    #Install necessary dependencies
    if [ "$OS" == 'CentOS' ]; then
        yum install -y wget unzip openssl-devel gcc swig python python-devel python-setuptools autoconf libtool libevent
        yum install -y automake make curl curl-devel zlib-devel perl perl-devel cpio expat-devel gettext-devel
    else
        apt-get -y update
        apt-get -y install python python-dev python-pip curl wget unzip gcc swig automake make perl cpio
    fi
    # Get IP address
    echo "Getting Public IP address, Please wait a moment..."
    IP=$(curl -s -4 icanhazip.com)
    if [[ "$IP" = "" ]]; then
        IP=$(curl -s -4 ipinfo.io/ip)
    fi
    echo -e "Your main public IP is\t\033[32m$IP\033[0m"
    echo ""
    #Current folder
    cur_dir=`pwd`
    cd $cur_dir
}

# Download files
function download_files(){
    if [ "$OS" == 'CentOS' ]; then
        if ! wget -t3 -T30 http://lamp.teddysun.com/ez_setup.py; then
            echo "Failed to download ez_setup.py!"
            exit 1
        fi
        # Download shadowsocks chkconfig file
        if ! wget --no-check-certificate https://raw.githubusercontent.com/teddysun/shadowsocks_install/master/shadowsocks -O /etc/init.d/shadowsocks; then
            echo "Failed to download shadowsocks chkconfig file!"
            exit 1
        fi
    else
        if ! wget --no-check-certificate https://raw.githubusercontent.com/teddysun/shadowsocks_install/master/shadowsocks-debian -O /etc/init.d/shadowsocks; then
            echo "Failed to download shadowsocks chkconfig file!"
            exit 1
        fi
    fi
}

# Config shadowsocks
function config_shadowsocks(){
    cat > /etc/shadowsocks.json<<-EOF
{
    "server":"0.0.0.0",
    "server_port":${shadowsocksport},
    "local_address":"127.0.0.1",
    "local_port":1080,
    "password":"${shadowsockspwd}",
    "timeout":300,
    "method":"aes-256-cfb",
    "fast_open":false
}
EOF
}

# iptables set
function iptables_set(){
    echo "iptables start setting..."
    /etc/init.d/iptables status 1>/dev/null 2>&1
    if [ $? -eq 0 ]; then
        /etc/init.d/iptables status | grep '${shadowsocksport}' | grep 'ACCEPT' >/dev/null 2>&1
        if [ $? -ne 0 ]; then
            /sbin/iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport ${shadowsocksport} -j ACCEPT
            /etc/init.d/iptables save
            /etc/init.d/iptables restart
        else
            echo "port ${shadowsocksport} has been set up."
        fi
    else
        echo "iptables looks like shutdown, please manually set it if necessary."
    fi
}

# Install Shadowsocks
function install_ss(){
    which pip > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        if [ "$OS" == 'CentOS' ]; then
            python ez_setup.py install
            easy_install pip
        fi
    fi
    if [ -f /usr/bin/pip ]; then
        pip install M2Crypto
        pip install greenlet
        pip install gevent
        pip install shadowsocks
        if [ -f /usr/bin/ssserver ] || [ -f /usr/local/bin/ssserver ]; then
            chmod +x /etc/init.d/shadowsocks
            # Add run on system start up
            if [ "$OS" == 'CentOS' ]; then
                chkconfig --add shadowsocks
                chkconfig shadowsocks on
            else
                update-rc.d shadowsocks defaults
            fi
            # Run shadowsocks in the background
            /etc/init.d/shadowsocks start
        else
            echo ""
            echo "Shadowsocks install failed! Please visit https://teddysun.com/342.html and contact."
            exit 1
        fi
        clear
        echo ""
        echo "Congratulations, shadowsocks install completed!"
        echo -e "Your Server IP: \033[41;37m ${IP} \033[0m"
        echo -e "Your Server Port: \033[41;37m ${shadowsocksport} \033[0m"
        echo -e "Your Password: \033[41;37m ${shadowsockspwd} \033[0m"
        echo -e "Your Local IP: \033[41;37m 127.0.0.1 \033[0m"
        echo -e "Your Local Port: \033[41;37m 1080 \033[0m"
        echo -e "Your Encryption Method: \033[41;37m aes-256-cfb \033[0m"
        echo ""
        echo "Welcome to visit:https://teddysun.com/342.html"
        echo "Enjoy it!"
        echo ""
        exit 0
    else
        echo ""
        echo "pip install failed! Please visit https://teddysun.com/342.html and contact."
        exit 1
    fi
}

# Uninstall Shadowsocks
function uninstall_shadowsocks(){
    printf "Are you sure uninstall Shadowsocks? (y/n) "
    printf "\n"
    read -p "(Default: n):" answer
    if [ -z $answer ]; then
        answer="n"
    fi
    if [ "$answer" = "y" ]; then
        ps -ef | grep -v grep | grep -v ps | grep -i "ssserver" > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            /etc/init.d/shadowsocks stop
        fi
        checkos
        if [ "$OS" == 'CentOS' ]; then
            chkconfig --del shadowsocks
        else
            update-rc.d -f shadowsocks remove
        fi
        # delete config file
        rm -f /etc/shadowsocks.json
        rm -f /var/run/shadowsocks.pid
        rm -f /etc/init.d/shadowsocks
        pip uninstall -y shadowsocks
        if [ $? -eq 0 ]; then
            echo "Shadowsocks uninstall success!"
        else
            echo "Shadowsocks uninstall failed!"
        fi
    else
        echo "uninstall cancelled, Nothing to do"
    fi
}

# Install Shadowsocks-python
function install_shadowsocks(){
    checkos
    rootness
    disable_selinux
    pre_install
    download_files
    config_shadowsocks
    if [ "$OS" == 'CentOS' ]; then
        if ! centosversion 7; then
            iptables_set
        fi
    fi
    install_ss
}

# Initialization step
action=$1
[  -z $1 ] && action=install
case "$action" in
install)
    install_shadowsocks
    ;;
uninstall)
    uninstall_shadowsocks
    ;;
*)
    echo "Arguments error! [${action} ]"
    echo "Usage: `basename $0` {install|uninstall}"
    ;;
esac

#定义变量
#授权文件自动生成url
APX=http://soft.91yun.org/soft/serverspeeder/apx1.php
#安装包下载地址
INSTALLPACK=http://soft.91yun.org/soft/serverspeeder/91yunserverspeeder.tar.gz
#判断版本支持情况的地址
CHECKSYSTEM=http://soft.91yun.org/soft/serverspeeder/checksystem.php
#bin下载地址
BIN=downloadurl

#先安装lsb_release

yum -y install lsb || {  apt-get update;apt-get install -y lsb; } || { echo "lsb_release没安装成功，程序暂停";exit 1; }
yum -y install curl || { apt-get update;apt-get install -y curl; } || { echo "curl自动安装失败，请自行手动安装curl后再重新开始";exit 1; }


#取操作系统的名称
Get_Dist_Name()
{
    if grep -Eqi "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
        DISTRO='CentOS'
        PM='yum'
    elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
        DISTRO='Debian'
        PM='apt'
    elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
        DISTRO='Ubuntu'
        PM='apt'		
	else
        DISTRO='unknow'
    fi
    Get_OS_Bit
}

Get_OS_Bit()
{
    if [[ `getconf WORD_BIT` = '32' && `getconf LONG_BIT` = '64' ]] ; then
        ver3='x64'
    else
        ver3='x32'
    fi
}


#如果不是centos，ubuntu或者debian，提示出错
if [ "$DISTRO" == "unknow" ]; then
	echo "一键脚本暂时只支持centos，ubuntu和debian的安装，其他系统请选择手动安装http://www.91yun.org/serverspeeder91yun"
	exit 1
fi
Get_Dist_Name
release=$DISTRO
#发行版本
if [ "$release" == "Debian" ]; then
	ver1str="lsb_release -rs | awk -F '.' '{ print \$1}'"
else
	ver1str="lsb_release -rs | awk -F '.' '{ print \$1\".\"\$2 }'"
fi
ver1=$(eval $ver1str)
#内核版本
ver2=`uname -r`
#锐速版本
ver4=3.10.61.0

echo "================================================="
echo "操作系统：$release "
echo "发行版本：$ver1 "
echo "内核版本：$ver2 "
echo "位数：$ver3 "
echo "锐速版本：$ver4 "
echo "================================================="


#下载支持的bin列表
curl "http://soft.91yun.org/soft/serverspeeder/serverspeederbin.txt" -o serverspeederbin.txt || { echo "文件下载失败，自动退出，可以前往http://www.91yun.org/serverspeeder91yun手动下载安装包";exit 1; }




#判断内核版本
grep -q "$release/$ver11[^/]*/$ver2/$ver3" serverspeederbin.txt
if [ $? == 1 ]; then
		#echo "没有找到内核"
	if [ "$release" == "CentOS" ]; then
		ver21=`echo $ver2 | awk -F '-' '{ print $1 }'`
		ver22=`echo $ver2 | awk -F '-' '{ print $2 }' | awk -F '.' '{ print $1 }'`
		#cat serverspeederbin.txt | grep -q  "$release/$ver1/$ver21-$ver22[^/]*/$ver3/"
		cat serverspeederbin.txt | grep -q  "$release/$ver11[^/]*/$ver21-$ver22[^/]*/$ver3/"

		if [ $? == 1 ]; then
			echo -e "\r\n"
			echo "锐速暂不支持该内核，程序退出.自动安装判断比较严格，你可以到http://www.91yun.org/serverspeeder91yun手动下载安装文件尝试不同版本"
			exit 1
		fi
		echo "没有完全匹配的内核，请选一个最接近的尝试，不确保一定成功,(如果有版本号重复的选项随便选一个就可以)"
		echo -e "您当前的内核为 \033[41;37m $ver2 \033[0m"
		cat serverspeederbin.txt | grep  "$release/$ver11[^/]*/$ver21-$ver22[^/]*/$ver3/"  | awk -F '/' '{ print NR"："$3 }'
	fi
	
	
	if [[ "$release" == "Ubuntu" ]] || [[ "$release" == "Debian" ]]; then
		ver21=`echo $ver2 | awk -F '-' '{ print $1 }'`
		ver22=`echo $ver2 | awk -F '-' '{ print $2 }'`
		cat serverspeederbin.txt | grep -q  "$release/$ver11[^/]*/$ver21(-)?$ver22[^/]*/$ver3/"

		if [ $? == 1 ]; then
			echo -e "\r\n"
			echo "锐速暂不支持该内核，程序退出.自动安装判断比较严格，你可以到http://www.91yun.org/serverspeeder91yun手动下载安装文件尝试不同版本"
			exit 1
		fi
		echo "没有完全匹配的内核，请选一个最接近的尝试，不确保一定成功,(如果有版本号重复的选项随便选一个就可以)"
		echo -e "您当前的内核为 \033[41;37m $ver2 \033[0m"
		cat serverspeederbin.txt | grep  "$release/$ver11[^/]*/$ver21(-)?$ver22[^/]*/$ver3/"  | awk -F '/' '{ print NR"："$3 }'
	fi	
	
	
	echo "请选择（输入数字序号）："	
	read cver2
	if [ "$cver2" == "" ]; then
		echo "未选择任何内核版本，脚本退出"
		exit 1
	fi
	
	if [ "$release" == "CentOS" ]; then
		cver2str="cat serverspeederbin.txt | grep  \"$release/$ver11[^/]*/$ver21-$ver22[^/]*/$ver3/\"  | awk -F '/' '{ print NR\"：\"\$3 }' | awk -F '：' '/"$cver2："/{ print \$2 }' | awk 'NR==1{print \$1}'"
	fi
	if [[ "$release" == "Ubuntu" ]] || [[ "$release" == "Debian" ]]; then
		cver2str="cat serverspeederbin.txt | grep  \"$release/$ver11[^/]*/$ver21-[^/]*/$ver3/\"  | awk -F '/' '{ print NR\"：\"\$3 }' | awk -F '：' '/"$cver2："/{ print \$2 }' awk 'NR==1{print \$1}'"
	fi	
	ver2=$(eval $cver2str)
	if [ "$ver2" == "" ]; then
        echo "脚本获得不了内核版本号，错误退出"
		exit 1
    fi
	#根据所选的内核版本，再回头确定大版本
	
fi
#判断锐速版本
grep -q "$release/$ver1/$ver2/$ver3/$ver4" serverspeederbin.txt
if [ $? == 1 ]; then
	grep -q "$release/$ver11[^/]*/$ver2/$ver3/$ver4" serverspeederbin.txt
	if [ $? == 1 ]; then
		echo -e "\r\n"
		echo -e "我们用的锐速安装文件是\033[41;37m 3.10.60.0  \033[0m，但这个内核没有匹配的，请选择一个接近的锐速版本号尝试，不确保一定可用,(如果有版本号重复的选项随便选一个就可以)"
		cat serverspeederbin.txt | grep  "$release/$ver11[^/]*/$ver2/$ver3/"  | awk -F '/' '{ print NR"："$5 }'
		echo "请选择锐速版本号（输入数字序号）：" 
			read cver4
		if [ "$cver4" == "" ]; then
			echo "未选择任何锐速版本，脚本退出"
			exit 1
		fi
			cver4str="cat serverspeederbin.txt | grep  \"$release/$ver11[^/]*/$ver2/$ver3/\"  | awk -F '/' '{ print NR\"：\"\$5 }' | awk -F '：' '/"$cver4："/{ print \$2 }' | awk 'NR==1{print \$1}'"
			ver4=$(eval $cver4str)
		if [ "$ver4" == "" ]; then
			echo "没取到锐速版本，程序出错退出。"
			exit 1
		fi	
	fi
	#根据锐速版本，内核版本，再回头确定使用的大版本。
	cver1str="cat serverspeederbin.txt | grep '$release/$ver11[^/]*/$ver2/$ver3/$ver4' | awk -F '/' 'NR==1{ print \$2 }'"
	ver1=$(eval $cver1str)
fi



BINFILESTR="cat serverspeederbin.txt | grep '$release/$ver1/$ver2/$ver3/$ver4/0' | awk -F '/' '{ print \$7 }'"
BINFILE=$(eval $BINFILESTR)
BIN="http://soft.91yun.org/soft/serverspeeder/bin/$release/$ver1/$ver2/$ver3/$ver4/$BINFILE"
echo $BIN
rm -rf serverspeederbin.txt






#先取外网ip，根据取得ip获得网卡，然后通过网卡获得mac地址。
# if [ "$1" == "" ]; then
	# IP=$(curl ipip.net | awk -F ' ' '{print $2}' | awk -F '：' '{print $2}')
	# NC="ifconfig | awk -F ' |:' '/$IP/{print a}{a=\$1}'"
	# NETCARD=$(eval $NC)
# else
	# NETCARD=eth0
# fi
# MACSTR="LANG=C ifconfig $NETCARD | awk '/HWaddr/{ print \$5 }' "
# MAC=$(eval $MACSTR)
# if [ "$MAC" = "" ]; then
# MACSTR="LANG=C ifconfig $NETCARD | awk '/ether/{ print \$2 }' "
# MAC=$(eval $MACSTR)
# fi	
# echo IP=$IP
# echo NETCARD=$NETCARD

if [ "$1" == "" ]; then
	MACSTR="LANG=C ifconfig eth0 | awk '/HWaddr/{ print \$5 }' "
	MAC=$(eval $MACSTR)
	if [ "$MAC" == "" ]; then
		MACSTR="LANG=C ifconfig eth0 | awk '/ether/{ print \$2 }' "
		MAC=$(eval $MACSTR)
	fi	
	if [ "$MAC" == "" ]; then
		MAC=$(ip link | awk -F ether '{print $2}' | awk NF | awk 'NR==1{print $1}')
	fi
else
	MAC=$1
fi	
echo MAC=$MAC

#如果自动取不到就要求手动输入
if [ "$MAC" = "" ]; then
echo "无法自动取得mac地址，请手动输入："
read MAC
echo "手动输入的mac地址是$MAC"
fi


#安装curl

yum -y install curl || { apt-get update;apt-get install -y curl; } || { echo "curl自动安装失败，请自行手动安装curl后再重新开始";exit 1; }


	
#下载安装包
echo "======================================"
echo "开始下载安装包。。。。"
echo "======================================"
wget -N -O 91yunserverspeeder.tar.gz  $INSTALLPACK
tar xfvz 91yunserverspeeder.tar.gz || { echo "下载安装包失败，请检查";exit 1; }

#下载授权文件
echo "======================================"
echo "开始下载授权文件。。。。"
echo "======================================"
curl "$APX?mac=$MAC" -o 91yunserverspeeder/apxfiles/etc/apx-20341231.lic || { echo "下载授权文件失败，请检查$APX?mac=$MAC";exit 1;}


#取得序列号
echo "======================================"
echo "开始修改配置文件。。。。"
echo "======================================"
SNO=$(curl "$APX?mac=$MAC&sno") || { echo "生成序列号失败，请检查";exit 1; }
echo "序列号：$SNO"
sed -i "s/serial=\"sno\"/serial=\"$SNO\"/g" 91yunserverspeeder/apxfiles/etc/config
rv=$release"_"$ver1"_"$ver2
sed -i "s/Debian_7_3.2.0-4-amd64/$rv/g" 91yunserverspeeder/apxfiles/etc/config

#下载bin文件
echo "======================================"
echo "开始下载bin运行文件。。。。"
echo "======================================"
curl $BIN -o "91yunserverspeeder/apxfiles/bin/acce-3.10.61.0-["$release"_"$ver1"_"$ver2"]" || { echo "下载bin运行文件失败，请检查";exit 1; }

#切换目录执安装文件
cd 91yunserverspeeder
bash install.sh

#禁止修改授权文件
chattr +i /serverspeeder/etc/apx*
#添加开机启动
chmod +x /etc/rc.d/rc.local
echo "/serverspeeder/bin/serverSpeeder.sh start" >> /etc/rc.local
#安装完显示状态
bash /serverspeeder/bin/serverSpeeder.sh status



/sbin/modprobe tcp_hybla
/etc/init.d/shadowsocks restart 