#!/bin/bash
APP=top10_high_cpu_process
INSTALL=$HOME/.$APP
LOG=/var/log/$APP

yum_install() {
  for pkg in "$@"; do
    rpm -q "$pkg" > /dev/null || yum install -y -q "$pkg" || true
  done
}

start_service() {
  systemctl enable "$1" && systemctl start "$1" || true
}

add_cron() {
  (crontab -l | grep -v $APP 2> /dev/null; echo "$1") | crontab -
}

yum_install cronie logrotate
start_service crond
# cron
[[ ! -d "$INSTALL" ]] && mkdir -p "$INSTALL"
[[ ! -d "$LOG" ]] && mkdir -p "$LOG"
cat <<EOF > $INSTALL/$APP.sh
#!/bin/bash
step=2
for (( i = 0; i < 60; i=(i+step) )); do
  date +%Y-%m-%d-%H-%M-%S >> $LOG/$APP.log
  ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 11 >> $LOG/$APP.log
  echo >> $LOG/$APP.log
  sleep \$step
done
EOF
chmod +x $INSTALL/$APP.sh
add_cron "* * * * * $INSTALL/$APP.sh"
# logrotate
cat <<EOF > /etc/logrotate.d/$APP
/var/log/$APP/$APP.log {
    daily
    rotate 1
    size 40M
    missingok
    compress
    copytruncate
}
EOF
