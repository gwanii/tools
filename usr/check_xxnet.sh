#!/bin/bash
set -euo pipefail
ok() {
  fk=$(https_proxy=http://127.0.0.1:8087 http_proxy=http://127.0.0.1:8087 curl -s --connect-timeout 3 --max-time 3 google.com)
  echo ${fk}|grep -q "http://www.google.com/" && echo "XX-Net is OK." && return 0
}

xxnet() {
  ps -ef|grep "XX-Net"|grep -v grep|head -n1|awk '{print $2}'|xargs kill -9 2>/dev/null || true
  ps -ef|grep "code/default/launcher/start.py"|grep -v grep|head -n1|awk '{print $2}'|xargs kill -9 2>/dev/null || true
  sed -i 's#launchWithHungup $ARGS#launchWithNoHungup $ARGS#g' /home/xx/Downloads/XX-Net-3.9.6/start
  echo "Start XX-Net." && sudo systemctl restart miredo && /home/xx/Downloads/XX-Net-3.9.6/start
}

ok || xxnet
