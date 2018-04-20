#!/bin/bash
set -euo pipefail
ok() {
  fk=$(https_proxy=http://127.0.0.1:8087 http_proxy=http://127.0.0.1:8087 curl -s --connect-timeout 3 --max-time 3 google.com)
  echo ${fk}|grep -q "http://www.google.com/" && echo "XX-Net is OK." && return 0
}

xxnet() {
  pgrep -a python | grep "code/[0-9].*[0-9]/launcher/start.py" | cut -d" " -f1 | xargs kill -9 2> /dev/null || true
  sed -i 's#launchWithHungup $ARGS#launchWithNoHungup $ARGS#g' /home/xx/Downloads/XX-Net-3.9.6/start
  echo "Start XX-Net." && sudo systemctl restart miredo && /home/xx/Downloads/XX-Net-3.9.6/start
}

ok || xxnet
