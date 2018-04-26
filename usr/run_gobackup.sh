#!/bin/bash
(crontab -l | grep -v gobackup 2> /dev/null; echo "0 0 * * * /usr/local/bin/gobackup perform >> ~/.gobackup/gobackup.log") | crontab
systemctl enable crond && systemctl start crond
