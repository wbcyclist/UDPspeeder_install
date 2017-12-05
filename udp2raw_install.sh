#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#============================================================#
#   System Required:  CentOS 6 or 7                          #
#   Description: Install udp2raw server for CentOS 6 or 7 #
#============================================================#

# Current folder
cur_dir=`pwd`
tmp_dir='/tmp/udp2raw'

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
    ver=$(wget --no-check-certificate -qO- https://api.github.com/repos/wangyu-/udp2raw-tunnel/releases/latest | grep 'tag_name' | cut -d\" -f4)
    [ -z ${ver} ] && echo "Error: Get udp2raw latest version failed" && exit 1
    udp2raw_ver="udp2raw_binaries"
    download_link="https://github.com/wangyu-/udp2raw-tunnel/releases/download/${ver}/udp2raw_binaries.tar.gz"
    init_script_link="https://raw.githubusercontent.com/wbcyclist/UDPspeeder_install/master/udp2raw_init"
}

print_info(){
    clear
    echo "#############################################################"
    echo "# Install or Uninstall udp2raw server for CentOS 6 or 7. #"
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

    # Set udp2raw config SERVER_LISTEN_IP
    echo "Please enter SERVER_LISTEN_IP:"
    read -p "(Default SERVER_LISTEN_IP: 0.0.0.0:7778):" SERVER_LISTEN_IP
    [ -z "${SERVER_LISTEN_IP}" ] && SERVER_LISTEN_IP="0.0.0.0:7778"
    echo
    echo "---------------------------"
    echo "SERVER_LISTEN_IP = ${SERVER_LISTEN_IP}"
    echo "---------------------------"
    echo

    # Set udp2raw config REMOTE_LISTEN_IP
    echo -e "Please enter REMOTE_LISTEN_IP:"
    read -p "(Default REMOTE_LISTEN_IP: 127.0.0.1:7777):" REMOTE_LISTEN_IP
    [ -z "${REMOTE_LISTEN_IP}" ] && REMOTE_LISTEN_IP="127.0.0.1:7777"
    echo
    echo "---------------------------"
    echo "REMOTE_LISTEN_IP = ${REMOTE_LISTEN_IP}"
    echo "---------------------------"
    echo

    # Set udp2raw config password
    echo -e "Please enter password:"
    read -p "(Default password: 123456):" KEY
    [ -z "${KEY}" ] && KEY="123456"
    echo
    echo "---------------------------"
    echo "password = ${KEY}"
    echo "---------------------------"
    echo

    echo
    echo "Press any key to start...or press Ctrl+C to cancel"
    char=`get_char`

    if [ -f /etc/init.d/udp2raw ]; then
        /etc/init.d/udp2raw stop
    fi
    # ps -ef | grep -v grep | grep -i "udp2raw" > /dev/null 2>&1
    # if [ $? -eq 0 ]; then
    #     killall udp2raw
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

# Download latest udp2raw
download_files(){
    if [ ! -d ${tmp_dir} ]; then
        mkdir -p ${tmp_dir}
    fi

    cd ${tmp_dir}
    download "${udp2raw_ver}.tar.gz" "${download_link}"
    download "udp2raw_init" "${init_script_link}"
}

# Config udp2raw
config_udp2raw(){
    if [ ! -d /etc/udp2raw ]; then
        mkdir -p /etc/udp2raw
    fi
    cat > /etc/udp2raw/udp2raw.conf<<-EOF
-s
-l ${SERVER_LISTEN_IP}
-r ${REMOTE_LISTEN_IP}
-a
-k ${KEY}
--raw-mode faketcp
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

# Install udp2raw
install_udp2raw(){
    get_latest_version
    pre_install
    download_files
    config_udp2raw
    #firewall_set

    cd ${tmp_dir}

    tar zxf ${udp2raw_ver}.tar.gz
    if [ `getconf LONG_BIT` -eq "64" ]; then
        cp -f udp2raw_amd64 /usr/local/bin/udp2raw
    else
        cp -f udp2raw_x86 /usr/local/bin/udp2raw
    fi
    chmod +x /usr/local/bin/udp2raw

    cp -f udp2raw_init /etc/init.d/udp2raw
    chmod +x /etc/init.d/udp2raw

    chkconfig --add udp2raw
    chkconfig udp2raw on
    # Start udp2raw
    /etc/init.d/udp2raw start
    if [ $? -eq 0 ]; then
        echo -e "[${green}Info${plain}] udp2raw start success!"
    else
        echo -e "[${yellow}Warning${plain}] udp2raw start failure!"
    fi

    rm -rf ${tmp_dir}

    clear
    echo
    echo -e "Congratulations, udp2raw server install completed!"
    echo -e "Your Server Config : /etc/udp2raw/udp2raw.conf"
    echo
    echo -e "`cat /etc/udp2raw/udp2raw.conf`"
    echo
    echo "Enjoy it!"
    echo
}

# Uninstall udp2raw
uninstall_udp2raw(){
    clear
    print_info
    printf "Are you sure uninstall udp2raw? (y/n)"
    printf "\n"
    read -p "(Default: n):" answer
    [ -z ${answer} ] && answer="n"

    if [ "${answer}" == "y" ] || [ "${answer}" == "Y" ]; then
        /etc/init.d/udp2raw stop
        # ps -ef | grep -v grep | grep -i "udp2raw" > /dev/null 2>&1
        # if [ $? -eq 0 ]; then
        #     killall udp2raw
        # fi

        chkconfig --del udp2raw
        rm -f /usr/local/bin/udp2raw
        rm -f /etc/init.d/udp2raw
        echo "udp2raw uninstall success!"
    else
        echo
        echo "uninstall cancelled, nothing to do..."
        echo
    fi
}

update_udp2raw(){
    clear
    get_latest_version
    print_info
    printf "Are you sure update udp2raw? (y/n)"
    printf "\n"
    read -p "(Default: n):" answer
    [ -z ${answer} ] && answer="n"

    if [ "${answer}" == "y" ] || [ "${answer}" == "Y" ]; then
        /etc/init.d/udp2raw stop

        download_files

        cd ${tmp_dir}

        tar zxf ${udp2raw_ver}.tar.gz
        if [ `getconf LONG_BIT` -eq "64" ]; then
            cp -f udp2raw_amd64 /usr/local/bin/udp2raw
        else
            cp -f udp2raw_x86 /usr/local/bin/udp2raw
        fi
        chmod +x /usr/local/bin/udp2raw

        cp -f udp2raw_init /etc/init.d/udp2raw
        chmod +x /etc/init.d/udp2raw

        # Start udp2raw
        /etc/init.d/udp2raw start
        if [ $? -eq 0 ]; then
            echo -e "[${green}Info${plain}] udp2raw start success!"
        else
            echo -e "[${yellow}Warning${plain}] udp2raw start failure!"
        fi

        rm -rf ${tmp_dir}
        echo "udp2raw update success!"
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
        ${action}_udp2raw
        ;;
    *)
        echo "Arguments error! [${action}]"
        echo "Usage: `basename $0` [install|uninstall|update]"
        ;;
esac