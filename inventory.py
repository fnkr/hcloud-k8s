#!/usr/bin/env python3
import json
import subprocess

def get_terraform_output():
    return json.loads(subprocess.check_output(["terraform", "output", "-json"]).decode('utf-8'))

def build_inventory(terraform_output):
    inventory = {
        '_meta': {
            'hostvars': {},
        },
        'all': {
            'hosts': [],
            'children': ['node'],
            'vars': {},
        },
        'node': {
            'hosts': [],
        },
    }

    terraform_output = get_terraform_output()
    node_names = terraform_output['node_names']['value']
    node_ipv4_addresses = terraform_output['node_ipv4_addresses']['value']
    inventory['all']['vars']['cluster_network_ip_range'] = terraform_output['cluster_network_ip_range']['value']

    for node in range(len(node_names)):
        node_name = node_names[node]
        inventory['_meta']['hostvars'][node_name] = {
            'ansible_host': node_ipv4_addresses[node],
        }
        inventory['all']['hosts'].append(node_name)
        inventory['node']['hosts'].append(node_name)

    return inventory

if __name__ == '__main__':
    print(json.dumps(build_inventory(get_terraform_output())))
