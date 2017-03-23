#!/usr/bin/env python2
# -*- coding: utf-8 -*-

#import sys
#reload(sys)
#sys.setdefaultencoding('utf-8')

import copy
import imp
import logging
import os
import smtplib
import subprocess
import threading
import time
from email.MIMEMultipart import MIMEMultipart
from email.mime.text import MIMEText
from email.header import Header
from email.utils import formataddr


class Mailer(object):

    def __init__(self, name='', template=''):
        self.name = name
        self.template = template

        msg = MIMEMultipart('alternative')
        msg['From'] = formataddr((str(Header(cfg.FFROM, 'utf-8')), cfg.FFROM))
        format_to = lambda x: formataddr((str(Header(x.split('@')[0], 'utf-8')), x))
        msg['To'] = ','.join([format_to(x.strip()) for x in cfg.TO])
        msg['Subject'] = Header(cfg.SUBJECT, 'utf-8')
        self.msg = msg

    def send(self, content):
        """Send mail, if failed then create new smtp conn and retry it."""
        msg = copy.deepcopy(self.msg)
        msg.attach(MIMEText(self.template.format(**content), 'html', 'utf-8'))

        while 1: 
            try:
                smtp = smtplib.SMTP(timeout=600)
                smtp.connect(cfg.MAIL_HOST, cfg.MAIL_PORT)
                smtp.login(cfg.MAIL_USER, cfg.MAIL_PASS)
                smtp.sendmail(cfg.MAIL_USER, cfg.RECEIVERS, msg.as_string())
                _log.info('<%s> mail send success.', self.name)
            except (smtplib.SMTPHeloError,
                    smtplib.SMTPServerDisconnected,
                    smtplib.SMTPSenderRefused,
                    smtplib.SMTPRecipientsRefused,
                    smtplib.SMTPDataError,
                    smtplib.SMTPException) as e:
                _log.error('<%s> mail send failed, SMTPException: %s', self.name, e)
                continue
            except Exception as e:
                _log.error('<%s> mail send failed, Unexpected error.', e)
                continue
            finally:
                try:
                    smtp.quit()
                except:
                    pass


class CronMailer(threading.Thread):

    def __init__(self, name=None, interval=60*30):
        super(CronMailer, self).__init__(name=name)
        self.interval = interval

    def delay(self):
        """Delay to xx:30 or 00:00."""
        now = time.localtime()
        hour = now.tm_hour
        mmin = now.tm_min
        sec = now.tm_sec
        
        if mmin != 30 and mmin != 0:
            d = 30 - mmin if mmin < 30 else 60 - mmin
            _log.info('Now time: %s, delay %s(min) to run', time.asctime(), d)
            time.sleep(d * 60 - sec)

    @property
    def content(self):
        return ''

    def run(self):
        self.delay()
        _log.info('Start running thread %s...', self.name)

        mailer = Mailer(name=self.name, template=self.template)

        while 1:
            now1 = time.localtime()
            content, willsend = self.content
            if willsend:
                mailer.send(content)
            now2 = time.localtime()
            delta = 60 * (now2.tm_min - now1.tm_min) + (now2.tm_sec - now1.tm_sec)

            time.sleep(self.interval - delta)

    def red(self, txt):
        if txt:
            return "<p style='color:red'>%s</p>" % txt
        return txt


    def bash(self, cmd):
        try:
            p = subprocess.Popen(['bash', '-c', cmd], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            out, err = p.communicate()
        except Exception as e:
            _log.error('Failed to exec command: %s, exception: %s', cmd, e)
            return 'error'
        if not err:
            return out
        _log.error('Failed to exec command: %s', cmd)
        return 'error'
    
    
    def mysql(self, sql):
        cmd = 'mysql -uroot -e"%s"' % sql
        return self.bash(cmd)
    
    
    def mysql_getcount(self, sql):
        result = self.mysql(sql)
        return result.split('\n')[1] if result != 'error' else result

class SysStats(CronMailer):

    def __init__(self, name='SysStats'):
        super(SysStats, self).__init__(name=name, interval=cfg.SYS_INTERVAL)
        self.template = cfg.SYS_STATS_TEMPLATE

    @property
    def content(self):
        self.cpu_percent = self.bash(cfg.CMD_CPU_PERCENT)
        self.mem_percent = self.bash(cfg.CMD_MEM_PERCENT)
        self.disk_percent = self.bash(cfg.CMD_DISK_PERCENT).strip().strip('\n').replace('\n', ', ')
        self.bw_percent = 'not supported'
        
        if any([self.check_cpu_percent, self.check_mem_percent,
                self.check_disk_percent or self.check_bw_percent]):
           values = {'cpu_percent': self.cpu_percent,
                     'mem_percent': self.mem_percent,
                     'disk_percent': self.disk_percent,
                     'bw_percent': self.bw_percent}
           return values, True
        return '', False

    @property
    def check_cpu_percent(self):
        result = False
        if self.cpu_percent != 'error':
            result = float(self.cpu_percent) > cfg.CPU_USAGE_GATE
        self.cpu_percent = self.red(self.cpu_percent)
        return result

    @property
    def check_mem_percent(self):
        result = False
        if self.mem_percent != 'error':
            result = float(self.mem_percent) > cfg.MEM_USAGE_GATE
        self.mem_percent = self.red(self.mem_percent)
        return result

    @property
    def check_disk_percent(self):
        result = False
        for x in self.disk_percent.split(','):
            p = x.strip().split(' ')[0]
            if int(p[:-1]) > cfg.DISK_USAGE_GATE:
                self.disk_percent = self.red(self.disk_percent)
                result = True
                break
        return result

    @property
    def check_bw_percent(self):
        return False


class ProcStatsMailer(CronMailer):

    def __init__(self, name='ProcStatsMailer'):
        super(ProcStatsMailer, self).__init__(name=name, interval=cfg.PROC_INTERVAL)
        self.template = cfg.PROC_STATS_TEMPLATE

    @property
    def content(self):
        stats = {p: 'Active' for p in cfg.PROCS}
        hasdown = False
        for p in cfg.PROCS:
            if not self.bash(cfg.CMD_PS % p):
                stats[p] = self.red('Down')
                hasdown = True
        return stats, hasdown


def main():
    threads = [SysStats(), ProcStatsMailer()]
    try:
        for t in threads:
            t.start()
    
        for t in threads:
            t.join()
    except threading.ThreadError:
        _log.error('ThreadError in main thread.')
        sys.exit(1);
    except Exception as e:
        _log.error(u'Unexpected error in main thread: %s.', e)
        sys.exit(1);


if __name__ == '__main__':
    help_msg = 'usage: alert.py [-h] [-c PATH] [--config-file PATH]'
    if len(sys.argv) == 1:
        cfgpath = os.sep.join([os.path.dirname(os.path.abspath(__file__)), 'alert.cfg'])
    elif len(sys.argv) == 3 and sys.argv[1] in ('-c', '--config-file'):
        cfgpath = os.path.abspath(sys.argv[2])
    elif len(sys.argv) == 2 and sys.argv[1] == '-h':
        print help_msg
        sys.exit(1)
    else:
        print 'Unknown option: %s' % ' '.join(sys.argv[1:])
        print help_msg
        sys.exit(1)

    # load config
    try:
        imp.load_source('cfg', cfgpath)
        import cfg
        print 'Load module <cfg> from source <%s>.' % cfgpath
    except IOError:
        print 'Config file not exists or error format.'
        sys.exit(1)

    # log settings
    logging.basicConfig(filename=cfg.LOG_FILE, level=cfg.LOG_LEVEL.upper(),
                        format=cfg.LOG_FORMAT, datefmt=cfg.DATE_FORMAT)
    console = logging.StreamHandler()
    console.setLevel(logging.DEBUG)
    console.setFormatter(logging.Formatter(cfg.LOG_FORMAT))
    logging.getLogger().addHandler(console)
    _log = logging.getLogger(__name__)

    _log.info('Start running...')
    _log.info('Mail settings: mail_host:%s, mail_user:%s.', cfg.MAIL_HOST, cfg.MAIL_USER)
    main()
