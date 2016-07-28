Iptables
==========
https://www.ibm.com/developerworks/cn/linux/network/s-netip/

https://www.frozentux.net/iptables-tutorial/cn/iptables-tutorial-cn-1.1.19.html

http://www.liugj.com/2013/04/Iptables-NAT/


** iptables [-t table] chain command [match] [target] **

- 如果信息包源自外界并前往系统，而且防火墙是打开的，那么内核将它传递到内核空间信息包过滤表的 INPUT 链。如果信息包源自系统内部或系统所连接的内部网上的其它源，并且此信息包要前往另一个外部系统， 那么信息包被传递到 OUTPUT 链。类似的，源自外部系统并前往外部系统的信息包被传递到 FORWARD 链。PREROUTING 链由指定信息包一到达防火墙就改变它们的规则所组成，而 POSTROUTING 链由指定正当信息包打算离开防火墙时改变它们的规则所组成cc



- table 
	
	* filter(default)
	
	* nat
	
	* mangle
	
- chain

	
	* INPUT, OUTPUT, FORWARD(filter)
	
	* PREROUTING, OUTPUT, POSTROUTING(nat)
	
	* PREROUTING, OUTPUT(mangle)
	
- command
	
	* -A, append a rule; e.g. ** $ iptables -A INPUT -s 205.168.0.1 -j ACCEPT **
	
	* -D, delete a rule; e.g. ** iptables -D INPUT --dport 80 -j DROP **
	
	* -P, set default rule for chain; e.g. ** iptables -P INPUT DROP **
	
	* -N, create a chain; e.g. ** iptables -N allowed-chain **
	
	* -F, clear rules; e.g. ** iptables -F FORWARD **
	
	* -L, list rules; e.g. ** iptables -L allowed-chain **
	
- match

	* -p, protocol; e.g. 
		
		** iptables -A INPUT -p TCP, UDP **
		
		** iptables -A INPUT -p ! ICMP **

		** iptables -A INPUT -p tcp --dport 22 -j ACCEPT  **
		
	* -s, source ip range; e.g.
		
		** iptables -A OUTPUT -s 192.168.1.1 **
		
		** iptables -A OUTPUT -s 192.168.0.0/24 **

		** iptables -A OUTPUT -s ! 203.16.1.89 **
		
	* -d, destination ip range; e.g.
	
- target

	* ACCEPT
	
	* DROP
	
	* REJECT
	
	* RETURN
	
	* DNAT
		
		* iptables -t nat -A PREROUTING -d 202.202.202.1 -p tcp --dport 110 -j DNAT --to-destination 192.168.0.102:110  

		* iptables -t nat -A POSTROUTING -d 192.168.0.102 -p tcp --dport 110 -j SNAT --to 192.168.0.1  
	
- graph

                               XXXXXXXXXXXXXXXXXX
                             XXX     Network    XXX
                               XXXXXXXXXXXXXXXXXX
                                       +
                                       |
                                       v
 +-------------+              +------------------+
 |table: filter| <---+        | table: nat       |
 |chain: INPUT |     |        | chain: PREROUTING|
 +-----+-------+     |        +--------+---------+
       |             |                 |
       v             |                 v
 [local process]     |           ****************          +--------------+
       |             +---------+ Routing decision +------> |table: filter |
       v                         ****************          |chain: FORWARD|
****************                                           +------+-------+
Routing decision                                                  |
****************                                                  |
       |                                                          |
       v                        ****************                  |
+-------------+       +------>  Routing decision  <---------------+
|table: nat   |       |         ****************
|chain: OUTPUT|       |               +
+-----+-------+       |               |
      |               |               v
      v               |      +-------------------+
+--------------+      |      | table: nat        |
|table: filter | +----+      | chain: POSTROUTING|
|chain: OUTPUT |             +--------+----------+
+--------------+                      |
                                      v
                               XXXXXXXXXXXXXXXXXX
                             XXX    Network     XXX
                               XXXXXXXXXXXXXXXXXX


	
	
