package main

import (
	"fmt"
	"net"
	"os"
	"sort"
	"time"

	ping "github.com/tatsushid/go-fastping"
)

type addrTTL struct {
	rtt  map[string]time.Duration
	addr []string
}

func (at *addrTTL) Len() int {
	return len(at.rtt)
}

func (at *addrTTL) Less(i, j int) bool {
	return at.rtt[at.addr[i]] < at.rtt[at.addr[j]]
}

func (at *addrTTL) Swap(i, j int) {
	at.addr[i], at.addr[j] = at.addr[j], at.addr[i]
}

var teredoServers = []string{
	"teredo.remlab.net",
	"teredo2.remlab.net",
	"teredo.trex.fi",
	"teredo.iks-jena.de",
	//"teredo.ngix.ne.kr",
	//"teredo.autotrans.consulintel.com",
	//"teredo.managemydedi.com",
	//"teredo.ipv6.microsoft.com",
	//"win10.ipv6.microsoft.com",
	//"win1710.ipv6.microsoft.com",
	//"win1711.ipv6.microsoft.com",
}

func main() {
	at := new(addrTTL)
	at.rtt = make(map[string]time.Duration)
	for _, host := range teredoServers {
		p := ping.NewPinger()
		ra, err := net.ResolveIPAddr("ip4", host)
		if err != nil {
			fmt.Println(err)
			continue
		}
		p.AddIPAddr(ra)
		p.OnRecv = func(addr *net.IPAddr, rtt time.Duration) {
			at.rtt[addr.String()] = rtt
			at.addr = append(at.addr, addr.String())
		}
		err = p.Run()
		if err != nil {
			fmt.Println(err)
		}

	}
	sort.Sort(at)
	fmt.Printf("Address: %s, RTT: %s\n", at.addr[0], at.rtt[at.addr[0]])
	conf := fmt.Sprintf("InterfaceName teredo\nServerAddress %s\nServerAddress2 %s\n", at.addr[0], at.addr[1])
	f, err := os.OpenFile("/etc/miredo.conf", os.O_TRUNC|os.O_WRONLY|os.O_CREATE, 0644)
	if err != nil {
		panic(err)
	}
	defer f.Close()
	if _, err := f.WriteString(conf); err != nil {
		panic(err)
	}
}
