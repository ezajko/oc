#!/usr/bin/env python
class FilterModule(object):
    def filters(self):
        return {"reverse_name": self.reverse_name,
                "nodes_names": self.nodes_names,
                "node_name": self.node_name,
                "inc": self.inc,
                }

    def reverse_name(self, ip):
        return ".".join(reversed(ip.split(".")[0:2])) + ".in-addr.arpa."

    def nodes_names(self, nodes_num, nodes_prefix, nodes_separator, nodes_padding):
        return ['{}{}{:0{prec}}'.format(nodes_prefix, nodes_separator, i, prec=nodes_padding) for i in range(1, nodes_num+1)]

    def node_name(self, i, nodes_prefix, nodes_separator, nodes_padding):
        return '{}{}{:0{prec}}'.format(nodes_prefix, nodes_separator, i, prec=nodes_padding)

    def inc(self, val):
        return int(val) + 1

