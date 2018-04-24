#!/bin/bash
INSTALL=$HOME/.top10_high_cpu_process
LOG=/var/log/top10_high_cpu_process

yum_install() {
  for pkg in "$@"; do
    rpm -q "$pkg" > /dev/null || yum install -y -q "$pkg" || true
  done
}

start_service() {
  systemctl enable "$1" && systemctl start "$1" || true
}

add_cron() {
  (crontab -l 2> /dev/null; echo "$1") | crontab -
}

yum_install cronie logrotate
start_service crond
# cron
[[ ! -d "$INSTALL" ]] && mkdir -p "$INSTALL"
[[ ! -d "$LOG" ]] && mkdir -p "$LOG"
cat <<EOF > $INSTALL/log_top10.sh
#!/bin/bash
LOG=/var/log/top10_high_cpu_process

step=2
for (( i = 0; i < 60; i=(i+step) )); do
  ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 11 > \$LOG/\$(date +%Y%m%d-%H%M%S).log
  sleep \$step
done
EOF
chmod +x $INSTALL/log_top10.sh
add_cron "* * * * * $INSTALL/log_top10.sh"
# logrotate
cat <<EOF > /etc/logrotate.d/top10_high_cpu_process
/var/log/top10_high_cpu_process/*.log {
    daily
    rotate 1
    size 50M
    missingok
    compress
    copytruncate
}
EOF
