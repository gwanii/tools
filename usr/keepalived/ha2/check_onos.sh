#!/bin/sh
SERVICE=onos/apache-karaf
NUM_OF_CHECK=3

check_daemon()
{
    ps -ef | grep -v grep | grep $1 > /dev/null
    return $?
}

if check_daemon "$SERVICE"; then
    exit 0
fi
#for (( i=1; i<=$NUM_OF_CHECK; i++ )); do
#    systemctl start $SERVICE
#    sleep 1
#    if check_daemon "$SERVICE"; then
#        exit 0
#    fi
#done
exit 1
