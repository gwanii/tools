Calico Etcd Data Model
=======================

1. Profile(rules, tags)

```/calico/v1/policy/profile/<network-id>/rules```

```
class Rules(namedtuple("Rules", ["id", "inbound_rules", "outbound_rules"])):
	...
class Rule(dict):
	ALLOWED_KEYS = ["protocol",
                    "src_tag",
                    "src_selector",
                    "src_ports",
                    "src_net",
                    "dst_tag",
                    "dst_selector",
                    "dst_ports",
                    "dst_net",
                    "icmp_type",
                    "icmp_code",
                    "action"]
    ...
```

```/calico/v1/policy/profile/<network-id>/tags```

```
self.tags = set()
```
