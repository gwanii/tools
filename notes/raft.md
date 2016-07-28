
Raft protocol:

- strong consistency 

- live demo: http://thesecretlivesofdata.com/raft/

- leader election
	
	* election timeout: random 150ms~300ms; follower->candidate
	* heartbeat timeout: leader
	
- log replication

- CP: consistent, partition-tolerance

- [hashicorp/raft](https://github.com/hashicorp/raft)


Gossip Protocol:

- eventual consistency

- AP: available, partition-tolerance

- [Serf](https://github.com/hashicorp/serf) is a tool for cluster membership, failure detection, and orchestration that is decentralized, fault-tolerant and highly available.
