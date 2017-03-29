#!/bin/bash
mysql -uroot -Dkeystone -e "update endpoint set url=REPLACE(url, 'http://20.20.20.20:', 'http://192.168.2.2:')"
