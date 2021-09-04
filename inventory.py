#!/usr/bin/env python3
import os
import json
import subprocess


def get_terraform_output():
    terraform = "terraform"
    if "TF_BIN" in os.environ and os.environ["TF_BIN"]:
        terraform = os.environ["TF_BIN"]
    tf_cmd = [terraform, "output", "-json"]
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
    try:
        inventory["node"]["vars"]["k8s_hcloud_token"] = \
            terraform_output["hcloud_token"]["value"]
    except KeyError:
        inventory["node"]["vars"]["k8s_hcloud_token"] = \
            os.environ["HCLOUD_TOKEN"]

    inventory["node"]["vars"]["k8s_cluster_name"] = \
        terraform_output["cluster_name"]["value"]

    inventory["node"]["vars"]["k8s_version"] = \
        terraform_output["k8s_version"]["value"]

    inventory["node"]["vars"]["k8s_initializer"] = \
        terraform_output["initializer"]["value"]

    inventory["node"]["vars"]["k8s_network_id"] = \
        terraform_output["cluster_network_id"]["value"]

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

    inventory["node"]["vars"]["k8s_private_control_plane_endpoint_alias"] = \
        "{{ k8s_cluster_name }}-control"

    inventory["node"]["vars"]["k8s_private_control_plane_endpoint"] = \
        "{{ k8s_private_control_plane_endpoint_alias }}:{{ k8s_private_control_plane_endpoint_port }}"

    inventory["node"]["vars"]["k8s_apiserver_cert_extra_sans"] = \
        terraform_output["controllb_ipv4_addresses"]["value"] + terraform_output["controllb_ipv6_addresses"]["value"]

    inventory["node"]["vars"]["k8s_ingress"] = \
        terraform_output["cluster_ingress"]["value"]

    inventory["node"]["vars"]["k8s_ingress_proxy_protocol"] = \
        terraform_output["cluster_ingress_proxy_protocol"]["value"]

    inventory["node"]["vars"]["k8s_cni"] = \
        terraform_output["cluster_cni"]["value"]

    inventory["node"]["vars"]["k8s_registry_mirrors"] = \
        terraform_output["registry_mirrors"]["value"]

    inventory["node"]["vars"]["k8s_install_hcloud_ccm"] = \
        terraform_output["install_hcloud_ccm"]["value"]

    inventory["node"]["vars"]["k8s_install_hcloud_csi"] = \
        terraform_output["install_hcloud_csi"]["value"]

    inventory["node"]["vars"]["k8s_install_cert_manager"] = \
        terraform_output["install_cert_manager"]["value"]

    inventory["node"]["vars"]["k8s_install_ceph_client"] = \
        terraform_output["install_ceph_client"]["value"]

    inventory["node"]["vars"]["k8s_install_reloader"] = \
        terraform_output["install_reloader"]["value"]
    # fmt: on

    for group in [
        [
            terraform_output["controlnode_names"]["value"],
            terraform_output["controlnode_ipv4_addresses"]["value"],
            "controlnode",
            terraform_output["cluster_network_ip_range_controlnode_pod"]["value"],
            terraform_output["controlnode_instance_types"]["value"],
            terraform_output["controlnode_regions"]["value"],
            terraform_output["controlnode_zones"]["value"],
        ],
        [
            terraform_output["workernode_names"]["value"],
            terraform_output["workernode_ipv4_addresses"]["value"],
            "workernode",
            terraform_output["cluster_network_ip_range_workernode_pod"]["value"],
            terraform_output["workernode_instance_types"]["value"],
            terraform_output["workernode_regions"]["value"],
            terraform_output["workernode_zones"]["value"],
        ],
    ]:
        for node in range(len(group[0])):
            node_name = group[0][node]
            node_ipv4_address = group[1][node]
            node_group = group[2]
            node_pod_cidr = group[3][node] if group[3] else None
            node_instance_type = group[4][node]
            node_region = group[5][node]
            node_zone = group[6][node]

            inventory["_meta"]["hostvars"][node_name] = {
                "ansible_host": node_ipv4_address,
                "ansible_user": "root",
                "k8s_private_control_plane_endpoint_ip": terraform_output[
                    f"controllb_private_k8s_endpoint_ips_for_{node_group}s"
                ]["value"][node],
                "k8s_private_control_plane_endpoint_port": terraform_output[
                    "controllb_private_k8s_endpoint_port"
                ]["value"],
                "k8s_ip_range_node_pod": node_pod_cidr,
                "k8s_instance_type": node_instance_type,
                "k8s_region": node_region,
                "k8s_zone": node_zone,
            }
            inventory[node_group]["hosts"].append(node_name)
            inventory["node"]["vars"][f"k8s_{node_group}s"].append(node_name)

    return inventory


if __name__ == "__main__":
    print(json.dumps(build_inventory(get_terraform_output())))
