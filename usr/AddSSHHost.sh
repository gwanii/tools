#!/bin/bash
usage() {
    cat << EOF
NAME
    ASH - Add SSH Host

SYNOPSIS
    $prog COMMAND [OPTIONS]

DESCRIPTION
    A tool to add SSH host.

OPTIONS
    -h        Show this help
    -i        Remote host IP
    -H        Remote host name
    -u        Remote host user (default: root)
    -p        Remote host password (if not specified, read pass from prompt)
EOF
exit 0
}


user=root
pass=""
while getopts ":H:u:i:p:h" opt
do
    case "$opt" in 
        h ) usage ;;
        i ) ip=${OPTARG} ;;
        H ) host=${OPTARG} ;;
        u ) user=${OPTARG} ;;
        p ) pass=${OPTARG} ;;
        * ) usage ;;
    esac
done
[[ "x"$host == "x" ]] || [[ "x"$ip == "x" ]] && usage && exit 1


if [[ "x"$(cat ~/.ssh/config | grep "Host $host") == "x" ]]; then
cat <<EOF >> ~/.ssh/config

Host $host
  HostName $ip
  User $user
  Port 22
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
  PasswordAuthentication no
  IdentityFile ~/.ssh/id_rsa
  IdentitiesOnly yes
  LogLevel FATAL
  ForwardAgent yes
EOF
fi
sci="ssh-copy-id $user@$ip"
[[ "x"$pass == "x" ]] && $sci || sshpass -p $pass $sci
