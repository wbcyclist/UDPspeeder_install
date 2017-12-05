# UDPspeeder_install
UDPspeeder安装脚本

## 安装
使用 root 用户登录

```
wget --no-check-certificate -O UDPspeeder_install.sh https://raw.githubusercontent.com/wbcyclist/UDPspeeder_install/master/UDPspeeder_install.sh
chmod +x UDPspeeder_install.sh
./UDPspeeder_install.sh
```

## 卸载
使用 root 用户登录

```
./UDPspeeder_install.sh uninstall
```

## 升级
使用 root 用户登录

```
./UDPspeeder_install.sh update
```


## 使用

```
/etc/init.d/UDPspeeder start|stop|restart|status
```

## 默认配置文件路径
/etc/UDPspeeder/speederv2_config.sh

```
SERVER_LISTEN_IP="0.0.0.0:7777"
REMOTE_LISTEN_IP="127.0.0.1:433"
KEY="passwd123"
FEC_MODE="0"
FEC_MTU="1250"
FEC_QUEUE_LEN="200"
FEC="20:10"
# 0: never    1: fatal   2: error   3: warn 
# 4: info (default)      5: debug   6: trace
LOG_LEVEL="4"
LOG_FILE="/var/log/UDPspeeder/speederv2.log"

#OTHER_OPTIONS="--timeout 10 --log-position -i 0"
```

# udp2raw-tunnel
udp2raw-tunnel安装脚本

## 安装
使用 root 用户登录

```
wget --no-check-certificate -O udp2raw_install.sh https://raw.githubusercontent.com/wbcyclist/UDPspeeder_install/master/udp2raw_install.sh
chmod +x udp2raw_install.sh
./udp2raw_install.sh
```

## 卸载
使用 root 用户登录

```
./udp2raw_install.sh uninstall
```

## 升级
使用 root 用户登录

```
./udp2raw_install.sh update
```


## 使用

```
/etc/init.d/udp2raw start|stop|restart|status
```

## 默认配置文件路径
/etc/udp2raw/udp2raw.conf

```
-s
-l 0.0.0.0:7778
-r 127.0.0.1:7777
-a
-k passwd
--raw-mode faketcp
```




