#!/bin/bah

# on controller node
yum install ntp

sed -i 's/^restrict/#restrict/g' /etc/ntp.conf

cat <<EOF >> /etc/ntp.conf
restrict -4 default kod notrap nomodify
restrict -6 default kod notrap nomodify
EOF

systemctl enable ntpd && systemctl restart ntpd


# on other nodes
yum install ntp

sed -i 's/^server/#server/g' /etc/ntp.conf
echo "server 192.168.9.122 iburst" >> /etc/ntp.conf

systemctl enable ntpd && systemctl restart ntpd
