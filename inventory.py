#!/usr/bin/env python3
import os
import json
import subprocess


def get_terraform_output():
    tf_cmd = ["terraform", "output", "-json"]
    if "TF_STATE" in os.environ:
        tf_cmd.extend(["-state", os.environ["TF_STATE"]])
    return json.loads(subprocess.check_output(tf_cmd).decode("utf-8"))


def build_inventory(terraform_output):
    inventory = {
        "_meta": {
            "hostvars": {},
        },
        "all": {
            "children": ["node"],
        },
        "node": {
            "children": ["controlnode", "workernode"],
            "vars": {
                "k8s_controlnodes": [],
                "k8s_workernodes": [],
            },
        },
        "controlnode": {
            "hosts": [],
        },
        "workernode": {
            "hosts": [],
        },
    }

    terraform_output = get_terraform_output()

    # fmt: off
    inventory["node"]["vars"]["k8s_hcloud_token"] = \
        terraform_output["hcloud_token"]["value"]

    inventory["node"]["vars"]["k8s_cluster_name"] = \
        terraform_output["cluster_name"]["value"]

    inventory["node"]["vars"]["k8s_version"] = \
        terraform_output["k8s_version"]["value"]

    inventory["node"]["vars"]["k8s_initializer"] = \
        terraform_output["initializer"]["value"]

    inventory["node"]["vars"]["k8s_ip_range"] = \
        terraform_output["cluster_network_ip_range"]["value"]

    inventory["node"]["vars"]["k8s_ip_range_controlnode"] = \
        terraform_output["cluster_network_ip_range_controlnode"]["value"]

    inventory["node"]["vars"]["k8s_ip_range_workernode"] = \
        terraform_output["cluster_network_ip_range_workernode"]["value"]

    inventory["node"]["vars"]["k8s_ip_range_service"] = \
        terraform_output["cluster_network_ip_range_service"]["value"]

    inventory["node"]["vars"]["k8s_ip_range_pod"] = \
        terraform_output["cluster_network_ip_range_pod"]["value"]

    inventory["node"]["vars"]["k8s_control_plane_endpoint"] = \
        terraform_output["controllb_k8s_endpoint"]["value"]

    inventory["node"]["vars"]["k8s_apiserver_cert_extra_sans"] = \
        [terraform_output["controllb_ipv4_address"]["value"]]

    inventory["node"]["vars"]["k8s_ingress"] = \
        terraform_output["cluster_ingress"]["value"]

    inventory["node"]["vars"]["k8s_cni"] = \
        terraform_output["cluster_cni"]["value"]

    inventory["node"]["vars"]["k8s_registry_mirrors"] = \
        terraform_output["registry_mirrors"]["value"]
    # fmt: on

    for group in [
        [
            terraform_output["controlnode_names"]["value"],
            terraform_output["controlnode_ipv4_addresses"]["value"],
            "controlnode",
        ],
        [
            terraform_output["workernode_names"]["value"],
            terraform_output["workernode_ipv4_addresses"]["value"],
            "workernode",
        ],
    ]:
        for node in range(len(group[0])):
            node_name = group[0][node]
            node_ipv4_address = group[1][node]
            node_group = group[2]

            inventory["_meta"]["hostvars"][node_name] = {
                "ansible_host": node_ipv4_address,
                "ansible_user": "root",
                "k8s_private_control_plane_endpoint_ip": terraform_output[
                    f"controllb_private_k8s_endpoint_ips_for_{node_group}s"
                ]["value"][node],
                "k8s_private_control_plane_endpoint_port": terraform_output[
                    "controllb_private_k8s_endpoint_port"
                ]["value"],
            }
            inventory[node_group]["hosts"].append(node_name)
            inventory["node"]["vars"][f"k8s_{node_group}s"].append(node_name)

    return inventory


if __name__ == "__main__":
    print(json.dumps(build_inventory(get_terraform_output())))
