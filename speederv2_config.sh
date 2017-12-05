# 游戏
#./speederv2 -s -l0.0.0.0:4096 -r127.0.0.1:7777 -k "passwd" --mode 0 -f2:4 -q1
# 其他
#./speederv2 -s -l0.0.0.0:4096 -r127.0.0.1:7777 -k "passwd" --mode 0  -f20:10

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
