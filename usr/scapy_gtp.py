#!/usr/bin/env python

# Packet: Eth | IPv4 | UDP | GTP | IPv4 | Data

import binascii

from scapy.all import *
from scapy.contrib.gtp import GTPHeader

dip4 = '192.168.7.7'
sip4 = '192.168.8.8'
dport = 2152
sport = 2152
teid = 1

hex_path = './hex'

eth = Ether()
ip = IP(dst=dip4, src=sip4)
udp = UDP(dport=dport, sport=sport)

with open(hex_path, 'r') as hexfile:
    data = binascii.unhexlify(''.join(hexfile.readlines()).strip().replace(' ', '').replace('\n', ''))

gtp = GTPHeader(teid=teid, gtp_type=0xff, length=548, S=0)
gtp.add_payload(data)

#wrpcap('gtp.pcap', eth/ip/udp/gtp)
send(p)
