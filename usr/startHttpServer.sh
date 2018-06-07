#!/bin/bash
SERVER_DIR=/var/lib/jenkins/release
SERVER_PORT=5555
# cd $SERVER_DIR
# nohup python3 -m http.server $SERVER_PORT >/dev/null 2>&1 &

cat <<EOF >/usr/lib/systemd/system/simplehttpd.service
[Unit]
Description=Simple Python HTTP Server
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/simplehttpd
Restart=always
RestartSec=5s
TimeoutSec=300

[Install]
WantedBy=multi-user.target
EOF

cat <<EOF >/usr/local/bin/simplehttpd
#!/bin/bash
cd $SERVER_DIR
python3 -mhttp.server $SERVER_PORT
EOF

systemctl daemon-reload
systemctl restart simplehttpd
