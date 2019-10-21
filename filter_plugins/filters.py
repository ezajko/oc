#!/usr/bin/env python
class FilterModule(object):
    def filters(self):
        return {"reverse_name": self.reverse_name}

    def reverse_name(self, ip):
        return ".".join(reversed(ip.split(".")[0:2])) + ".in-addr.arpa."
