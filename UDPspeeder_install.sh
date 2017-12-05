#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#============================================================#
#   System Required:  CentOS 6 or 7                          #
#   Description: Install UDPspeeder server for CentOS 6 or 7 #
#============================================================#

# Current folder
cur_dir=`pwd`
tmp_dir='/tmp/UDPspeeder'

# Color
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

# Make sure only root can run our script
[[ $EUID -ne 0 ]] && echo -e "[${red}Error${plain}] This script must be run as root!" && exit 1


get_char(){
    SAVEDSTTY=`stty -g`
    stty -echo
    stty cbreak
    dd if=/dev/tty bs=1 count=1 2> /dev/null
    stty -raw
    stty echo
    stty $SAVEDSTTY
}

get_latest_version(){
    ver=$(wget --no-check-certificate -qO- https://api.github.com/repos/wangyu-/UDPspeeder/releases/latest | grep 'tag_name' | cut -d\" -f4)
    [ -z ${ver} ] && echo "Error: Get UDPspeeder latest version failed" && exit 1
    speederv2_ver="speederv2_binaries"
    download_link="https://github.com/wangyu-/UDPspeeder/releases/download/${ver}/speederv2_binaries.tar.gz"
    init_script_link="https://raw.githubusercontent.com/wbcyclist/UDPspeeder_install/master/UDPspeeder_init"
}

print_info(){
    clear
    echo "#############################################################"
    echo "# Install or Uninstall UDPspeeder server for CentOS 6 or 7. #"
    echo "# Github: https://github.com/wbcyclist/UDPspeeder_install   #"
    echo "#############################################################"
    echo
}

# Check system
check_sys(){
    local checkType=$1
    local value=$2

    local release=''
    local systemPackage=''

    if [[ -f /etc/redhat-release ]]; then
        release="centos"
        systemPackage="yum"
    elif cat /etc/issue | grep -Eqi "debian"; then
        release="debian"
        systemPackage="apt"
    elif cat /etc/issue | grep -Eqi "ubuntu"; then
        release="ubuntu"
        systemPackage="apt"
    elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
        release="centos"
        systemPackage="yum"
    elif cat /proc/version | grep -Eqi "debian"; then
        release="debian"
        systemPackage="apt"
    elif cat /proc/version | grep -Eqi "ubuntu"; then
        release="ubuntu"
        systemPackage="apt"
    elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
        release="centos"
        systemPackage="yum"
    fi

    if [[ ${checkType} == "sysRelease" ]]; then
        if [ "$value" == "$release" ]; then
            return 0
        else
            return 1
        fi
    elif [[ ${checkType} == "packageManager" ]]; then
        if [ "$value" == "$systemPackage" ]; then
            return 0
        else
            return 1
        fi
    fi
}

# Get version
getversion(){
    if [[ -s /etc/redhat-release ]]; then
        grep -oE  "[0-9.]+" /etc/redhat-release
    else
        grep -oE  "[0-9.]+" /etc/issue
    fi
}

# CentOS version
centosversion(){
    if check_sys sysRelease centos; then
        local code=$1
        local version="$(getversion)"
        local main_ver=${version%%.*}
        if [ "$main_ver" == "$code" ]; then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
}

# Pre-installation settings
pre_install(){
    # Check OS system
    if check_sys sysRelease centos; then
        # Not support CentOS 5
        if centosversion 5; then
            echo -e "[${red}Error${plain}] Not support CentOS 5, please change to CentOS 6 or 7 and try again."
            exit 1
        fi
    else
        echo -e "[${red}Error${plain}] Your OS is not supported to run it, please change OS to CentOS and try again."
        exit 1
    fi

    # apt-get install psmisc
    # yum install -y psmisc

    # Set UDPspeeder config SERVER_LISTEN_IP
    echo "Please enter SERVER_LISTEN_IP:"
    read -p "(Default SERVER_LISTEN_IP: 0.0.0.0:7777):" SERVER_LISTEN_IP
    [ -z "${SERVER_LISTEN_IP}" ] && SERVER_LISTEN_IP="0.0.0.0:7777"
    echo
    echo "---------------------------"
    echo "SERVER_LISTEN_IP = ${SERVER_LISTEN_IP}"
    echo "---------------------------"
    echo

    # Set UDPspeeder config REMOTE_LISTEN_IP
    echo -e "Please enter REMOTE_LISTEN_IP:"
    read -p "(Default REMOTE_LISTEN_IP: 127.0.0.1:8433):" REMOTE_LISTEN_IP
    [ -z "${REMOTE_LISTEN_IP}" ] && REMOTE_LISTEN_IP="127.0.0.1:8433"
    echo
    echo "---------------------------"
    echo "REMOTE_LISTEN_IP = ${REMOTE_LISTEN_IP}"
    echo "---------------------------"
    echo

    # Set UDPspeeder config password
    echo -e "Please enter password:"
    read -p "(Default password: 123456):" KEY
    [ -z "${KEY}" ] && KEY="123456"
    echo
    echo "---------------------------"
    echo "password = ${KEY}"
    echo "---------------------------"
    echo

    # Set UDPspeeder config FEC
    echo -e "Please enter FEC:"
    read -p "(Default FEC: 20:10):" FEC
    [ -z "${FEC}" ] && FEC="20:10"
    echo
    echo "---------------------------"
    echo "FEC = ${FEC}"
    echo "---------------------------"
    echo

    echo
    echo "Press any key to start...or press Ctrl+C to cancel"
    char=`get_char`

    if [ -f /etc/init.d/UDPspeeder ]; then
        /etc/init.d/UDPspeeder stop
    fi
    # ps -ef | grep -v grep | grep -i "speederv2" > /dev/null 2>&1
    # if [ $? -eq 0 ]; then
    #     killall speederv2
    # fi
}

download() {
    local filename=${1}
    local cur_dir=`pwd`
    if [ -s ${filename} ]; then
        echo -e "[${green}Info${plain}] ${filename} [found]"
    else
        echo -e "[${green}Info${plain}] ${filename} not found, download now..."
        wget --no-check-certificate -cq -t3 -T3 -O ${1} ${2}
        if [ $? -eq 0 ]; then
            echo -e "[${green}Info${plain}] ${filename} download completed..."
        else
            echo -e "[${red}Error${plain}] Failed to download ${filename}, please download it to ${cur_dir} directory manually and try again."
            exit 1
        fi
    fi
}

# Download latest UDPspeeder
download_files(){
    if [ ! -d ${tmp_dir} ]; then
        mkdir -p ${tmp_dir}
    fi

    cd ${tmp_dir}
    download "${speederv2_ver}.tar.gz" "${download_link}"
    download "UDPspeeder_init" "${init_script_link}"
}

# Config UDPspeeder
config_speederv2(){
    if [ ! -d /etc/UDPspeeder ]; then
        mkdir -p /etc/UDPspeeder
    fi
    cat > /etc/UDPspeeder/speederv2_config.sh<<-EOF
SERVER_LISTEN_IP="${SERVER_LISTEN_IP}"
REMOTE_LISTEN_IP="${REMOTE_LISTEN_IP}"
KEY="${KEY}"
FEC_MODE="0"
FEC_MTU="1250"
FEC_QUEUE_LEN="200"
FEC="${FEC}"
LOG_LEVEL="4"
LOG_FILE="/var/log/UDPspeeder/speederv2.log"

#OTHER_OPTIONS="--timeout 10 --log-position -i 0"
EOF
}

# Firewall set
firewall_set(){
    echo -e "[${green}Info${plain}] firewall set start..."
    if centosversion 6; then
        /etc/init.d/iptables status > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            iptables -L -n | grep -i ${server_port} > /dev/null 2>&1
            if [ $? -ne 0 ]; then
                iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport ${server_port} -j ACCEPT
                iptables -I INPUT -m state --state NEW -m udp -p udp --dport ${server_port} -j ACCEPT
                /etc/init.d/iptables save
                /etc/init.d/iptables restart
            else
                echo -e "[${green}Info${plain}] port ${server_port} has been set up."
            fi
        else
            echo -e "[${yellow}Warning${plain}] iptables looks like shutdown or not installed, please manually set it if necessary."
        fi
    elif centosversion 7; then
        systemctl status firewalld > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            firewall-cmd --permanent --zone=public --add-port=${server_port}/tcp
            firewall-cmd --permanent --zone=public --add-port=${server_port}/udp
            firewall-cmd --reload
        else
            echo -e "[${yellow}Warning${plain}] firewalld looks like not running or not installed, please enable port ${server_port} manually if necessary."
        fi
    fi
    echo -e "[${green}Info${plain}] firewall set completed..."
}

# Install UDPspeeder
install_udpspeeder(){
    get_latest_version
    pre_install
    download_files
    config_speederv2
    #firewall_set

    cd ${tmp_dir}

    tar zxf ${speederv2_ver}.tar.gz
    if [ `getconf LONG_BIT` -eq "64" ]; then
        cp -f speederv2_amd64 /usr/local/bin/speederv2
    else
        cp -f speederv2_x86 /usr/local/bin/speederv2
    fi
    chmod +x /usr/local/bin/speederv2

    cp -f UDPspeeder_init /etc/init.d/UDPspeeder
    chmod +x /etc/init.d/UDPspeeder

    chkconfig --add UDPspeeder
    chkconfig UDPspeeder on
    # Start UDPspeeder
    /etc/init.d/UDPspeeder start
    if [ $? -eq 0 ]; then
        echo -e "[${green}Info${plain}] UDPspeeder start success!"
    else
        echo -e "[${yellow}Warning${plain}] UDPspeeder start failure!"
    fi

    rm -rf ${tmp_dir}

    clear
    echo
    echo -e "Congratulations, UDPspeeder server install completed!"
    echo -e "Your Server Config : /etc/UDPspeeder/speederv2_config.sh"
    echo
    echo -e "`cat /etc/UDPspeeder/speederv2_config.sh`"
    echo
    echo "Enjoy it!"
    echo
}

# Uninstall UDPspeeder
uninstall_udpspeeder(){
    clear
    print_info
    printf "Are you sure uninstall UDPspeeder? (y/n)"
    printf "\n"
    read -p "(Default: n):" answer
    [ -z ${answer} ] && answer="n"

    if [ "${answer}" == "y" ] || [ "${answer}" == "Y" ]; then
        /etc/init.d/UDPspeeder stop
        # ps -ef | grep -v grep | grep -i "speederv2" > /dev/null 2>&1
        # if [ $? -eq 0 ]; then
        #     killall speederv2
        # fi

        chkconfig --del UDPspeeder
        rm -f /usr/local/bin/speederv2
        rm -f /etc/init.d/UDPspeeder
        echo "UDPspeeder uninstall success!"
    else
        echo
        echo "uninstall cancelled, nothing to do..."
        echo
    fi
}

update_udpspeeder(){
    clear
    get_latest_version
    print_info
    printf "Are you sure update UDPspeeder? (y/n)"
    printf "\n"
    read -p "(Default: n):" answer
    [ -z ${answer} ] && answer="n"

    if [ "${answer}" == "y" ] || [ "${answer}" == "Y" ]; then
        /etc/init.d/UDPspeeder stop

        download_files

        cd ${tmp_dir}

        tar zxf ${speederv2_ver}.tar.gz
        if [ `getconf LONG_BIT` -eq "64" ]; then
            cp -f speederv2_amd64 /usr/local/bin/speederv2
        else
            cp -f speederv2_x86 /usr/local/bin/speederv2
        fi
        chmod +x /usr/local/bin/speederv2

        cp -f UDPspeeder_init /etc/init.d/UDPspeeder
        chmod +x /etc/init.d/UDPspeeder

        # Start UDPspeeder
        /etc/init.d/UDPspeeder start
        if [ $? -eq 0 ]; then
            echo -e "[${green}Info${plain}] UDPspeeder start success!"
        else
            echo -e "[${yellow}Warning${plain}] UDPspeeder start failure!"
        fi

        rm -rf ${tmp_dir}
        echo "UDPspeeder update success!"
    else
        echo
        echo "update cancelled, nothing to do..."
        echo
    fi
}

# Initialization step
action=$1
[ -z $1 ] && action=install
case "$action" in
    install|uninstall|update)
        ${action}_udpspeeder
        ;;
    *)
        echo "Arguments error! [${action}]"
        echo "Usage: `basename $0` [install|uninstall|update]"
        ;;
esac