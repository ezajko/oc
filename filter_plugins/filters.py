#!/usr/bin/env python

from ansible.parsing.dataloader import DataLoader
from ansible.template import Templar
from ansible.vars.manager import VariableManager
from ansible.utils.display import Display

display = Display()


def render(template, **kwargs):
    return Templar(DataLoader(), variables=kwargs).template(
        template, convert_bare=True, fail_on_undefined=True
    )


def extra_vars():
    return VariableManager(loader=DataLoader()).extra_vars


class FilterModule(object):
    _filters = {}

    def filters(self):
        return self.__class__._filters

    @classmethod
    def filter(cls, func):
        cls._filters[func.__name__] = func
        return func


@FilterModule.filter
def reverse_name(ip):
    return ".".join(reversed(ip.split(".")[0:2])) + ".in-addr.arpa."


@FilterModule.filter
def nodes_names(nodes_num, nodes_prefix=None, nodes_separator=None, nodes_padding=None):
    extra_vars_ = extra_vars()
    nodes_prefix = extra_vars_["nodes_prefix"]
    nodes_padding = extra_vars_["nodes_padding"]
    nodes_separator = extra_vars_["nodes_separator"]
    return [
        "{}{}{:0{prec}}".format(nodes_prefix, nodes_separator, i, prec=nodes_padding)
        for i in range(1, nodes_num + 1)
    ]


@FilterModule.filter
def node_name(i):
    extra_vars_ = extra_vars()
    nodes_prefix = extra_vars_["nodes_prefix"]
    nodes_padding = extra_vars_["nodes_padding"]
    nodes_separator = extra_vars_["nodes_separator"]
    return "{}{}{:0{prec}}".format(
        nodes_prefix, nodes_separator, i + 1, prec=nodes_padding
    )


@FilterModule.filter
def node_ip(i):
    return "{}".format(
        render(
            "sms_network_ip_start | ipmath(i)",
            i=i,
            sms_network_ip_start=extra_vars()["sms_network_ip_start"],
        )
    )


@FilterModule.filter
def node_bmc(i):
    return "{}".format(
        render(
            "service_network_ip_start | ipmath(i)",
            i=i,
            service_network_ip_start=extra_vars()["service_network_ip_start"],
        )
    )
