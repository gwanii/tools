#!/usr/bin/python
import subprocess
import hashlib
err, output = subprocess.getstatusoutput("glance image-list| awk '{print $2}'|grep -")
if not err:
    for line in output.split('\n'):
        print(line, hashlib.sha1(bytes(line, 'utf-8')).hexdigest())
