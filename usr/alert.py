#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
reload(sys)
sys.setdefaultencoding('utf-8')
import time
import logging
import smtplib
import subprocess
import threading
from email.MIMEMultipart import MIMEMultipart
from email.mime.text import MIMEText
from email.header import Header
from email.utils import formataddr


MAX_BEARERS = 100000

# mail setting
mail_host, mail_port = "xxx", 25
mail_user = ""
mail_pass = ""
receivers = ["", ""]
subject = u"xxx"
ffrom = mail_user
to = receivers

# mail notification interval
SYS_INTERVAL = 60*30

# cpu/mem/disk/bandwidth alerting gate
CPU_USAGE_GATE = 70
MEM_USAGE_GATE = 60
DISK_USAGE_GATE = 80
BW_USAGE_GATE = 0


SYS_STATS_TEMPLATE = u"""
<h3>系统资源利用率</h3>
<table border="1">
  <tr>
    <td>cpu usage percent(%)</td>
    <td>{cpu_percent}</td>
  </tr>

  <tr>
    <td>memory usage percent(%)</td>
    <td>{mem_percent}</td>
  </tr>

  <tr>
    <td>disk usage percent(%)</td>
    <td>{disk_percent}</td>
  </tr>

  <tr>
    <td>bandwidth usage percent(%)</td>
    <td>{bw_percent}</td>
  </tr>
</table>
"""


# system status shell command
cmd_cpu_percent = "top -b -n1 | grep \"Cpu(s)\" | awk '{print $2 + $4}'"
cmd_mem_percent = "free | grep Mem | awk '{printf \"%.2f\", $3/$2 * 100.0}'"
cmd_disk_percent = "df -H | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5 \" \" $6 }'"

log_format = '[%(asctime)s] [%(process)s] [%(levelname)s] [%(name)s] %(message)s'
date_format = '%Y-%m-%d %H:%M:%S %z'
logging.basicConfig(level=logging.INFO, format=log_format, datefmt=date_format)
_log = logging.getLogger(__name__)

red = lambda text: "<p style='color:red'>%s</p>" % text


def bash(cmd):
    p = subprocess.Popen(['bash', '-c', cmd], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = p.communicate()
    if not err:
        return out
    _log.error('Failed to exec command: %s', cmd)
    return 'error'


def send_mail(content):
    msg = MIMEMultipart('alternative')
    msg.attach(MIMEText(content, 'html', 'utf-8'))
    msg['From'] = formataddr((str(Header(ffrom, 'utf-8')), ffrom))
    format_to = lambda x: formataddr((str(Header(x.split('@')[0], 'utf-8')), x))
    msg['To'] = ','.join([format_to(x.strip()) for x in to])
    msg['Subject'] = Header(subject, 'utf-8')
    
    try:
        smtp = smtplib.SMTP()
        smtp.connect(mail_host, mail_port)
        smtp.login(mail_user, mail_pass)
        smtp.sendmail(mail_user, receivers, msg.as_string())
        _log.info(u'邮件发送成功')
    except smtplib.SMTPException:
        _log.error(u'Error: 无法发送邮件')
        raise


class SysStats(threading.Thread):
    def __init__(self):
        threading.Thread.__init__(self)

    def run(self):
        while 1:
            self.cpu_percent = bash(cmd_cpu_percent)
            self.mem_percent = bash(cmd_mem_percent)
            self.disk_percent = bash(cmd_disk_percent).strip().strip('\n').replace('\n', ', ')
            self.bw_percent = "not supported"
    
            if any([self.check_cpu_percent, self.check_mem_percent,
                    self.check_disk_percent or self.check_bw_percent]):
                content = SYS_STATS_TEMPLATE.format(
                    cpu_percent=self.cpu_percent,
                    mem_percent=self.mem_percent,
                    disk_percent=self.disk_percent,
                    bw_percent=self.bw_percent
                )
                send_mail(content)
            time.sleep(SYS_INTERVAL)

    @property
    def check_cpu_percent(self):
        result = float(self.cpu_percent) > CPU_USAGE_GATE
        if result:
            self.cpu_percent = red(self.cpu_percent)
        return result

    @property
    def check_mem_percent(self):
        result = float(self.mem_percent) > MEM_USAGE_GATE
        if result:
            self.mem_percent = red(self.mem_percent)
        return result

    @property
    def check_disk_percent(self):
        for x in self.disk_percent.split(','):
            p = x.strip().split(' ')[0]
            if int(p[:-1]) > DISK_USAGE_GATE:
                self.disk_percent = red(self.disk_percent)
                return True
        return False

    @property
    def check_bw_percent(self):
        return False


if __name__ == "__main__":
    threads = [SysStats(), ]

    for t in threads:
        t.start()

    for t in threads:
        t.join()
