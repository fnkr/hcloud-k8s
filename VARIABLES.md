## cluster_authorized_ssh_keys 

List of names of SSH keys in the Hetzner Cloud Project to be used for new servers.
At least one of the keys must be available on the local machine
so that Terraform and Ansible can use it to connect to servers.

Example: `["mykey"]`

Default: none

Change after cluster initialization:
Only applied to newly created servers.

## cluster_name

Will be used as prefix/name for servers, networks, load balancers, firewalls, ... 

Default: `"testkube"`

Change after cluster initialization:
Breaks cluster.

## cluster_controlnode_types

Server types for control nodes.
The more server types are specified, the more control nodes will be created.

Default: `["cx21", "cx21", "cx21"]`

Change after cluster initialization:
Should be safe (untested).

## cluster_controlnode_locations

Server locations for control nodes.
Number of items must equal number of items in `cluster_controlnode_types`.

Default: `["nbg1", "fsn1", "hel1"]`

Change after cluster initialization:
Should be safe (untested) as long as the first entry (initializer) isn't changed.

## cluster_workernode_types

Server types for worker nodes.
The more server types are specified, the more worker nodes will be created.

Default: `["cx21", "cx21", "cx21"]`

Change after cluster initialization:
Untested.

## cluster_workernode_locations

Server locations for worker nodes.
Number of items must equal number of items in `cluster_workernode_types`.

Default: `["nbg1", "fsn1", "hel1"]`

Change after cluster initialization:
Untested.

## cluster_controllb_types

Load balancer types for control node load balancers.
The more load balancer types are specified, the more load balancers will be created.

Default: `["lb11", "lb11", "lb11"]`

Change after cluster initialization:
Removing a load balancer will break nodes using that load balancer.
Only newly created nodes will use new load balancers.
Changing load balancer types is safe.

## cluster_controllb_locations

Locations for control node load balancers.
Number of items must equal number of items in `cluster_controllb_types`.

Nodes will use the first load balancer in the same location as Kubernetes API endpoint.
When there is no load balancer in the same location, the first load balancer from the list will be used.

Default: `["nbg1", "fsn1", "hel1"]`

Change after cluster initialization:
Removing a load balancer will break nodes using that load balancer.
Only newly created nodes will use new load balancers.
Changing locations of existing load balancers will cause recreation.

## cluster_workerlb_types

Load balancer types for worker node load balancers.
The more load balancer types are specified, the more load balancers will be created.

Default: `["lb11", "lb11"]`

Change after cluster initialization:
Safe.

## cluster_workerlb_locations

Locations for worker node load balancers.
Number of items must equal number of items in `cluster_workerlb_types`.

Default: `["nbg1", "fsn1"]`

Change after cluster initialization:
Changing locations of existing load balancers will cause recreation and new public IP addresses will be assigned.
Adding load balancers is safe.

## cluster_existing_network_name

Name of an existing Hetzner Cloud Network to be used.
If left empty, a new one will be created.

default: `""`

## cluster_network_zone

Zone for Hetzner Cloud Network.
Currently, there is only one possible value (`eu-central`).

Default: `"eu-central"`

Change after cluster initialization:
n/a

## cluster_network_ip_range

CIDR for the Hetzner Cloud Network.
Must be boarder then the CIDRs set for `cluster_network_ip_range_*`.

The first host IP (e.g. `10.8.0.1` if set to `10.8.0.0/14`) must not be
within any of the `cluster_network_ip_range_*` CIDRs.
This is because the IP will be used by Hetzner Cloud as gateway.

Default: `"10.8.0.0/14"`

Change after cluster initialization:
Cannot be changed.

## cluster_network_ip_range_controllb

IP range for control node load balancers.

Default: `"10.8.2.0/24"`

Change after cluster initialization:
Breaks cluster.

## cluster_network_ip_range_workerlb

IP range for worker node load balancers.

Default: `"10.8.3.0/24"`

Change after cluster initialization:
Should be safe (untested).

## cluster_network_ip_range_controlnode

IP range for control nodes.

Default: `"10.8.10.0/24"`

Change after cluster initialization:
Breaks cluster.

## cluster_network_ip_range_workernode

IP range for worker nodes.

Default: `"10.8.11.0/24"`

Change after cluster initialization:
Breaks cluster.

## cluster_network_ip_range_service

Kubernetes service CIDR.

Default: `"10.9.0.0/16"`

Change after cluster initialization:
Breaks cluster.

## cluster_network_ip_range_pod

Kubernetes Pod CIDR.

Default: `"10.10.0.0/15"`

Change after cluster initialization:
Breaks cluster.

## cluster_ingress

Ingress Controller to install. Only `"nginx"` and none (`""`) is currently supported.

Default: `"nginx"`

Change after cluster initialization:
Existing ingress controller will not be uninstalled automatically.

## cluster_cni

Container Network Interface to install. Supported values:

* `""` - Don't install any CNI
* `"cilium"` - Install Cilium CNI
* `"cilium-wireguard"` - Install Cilium CNI and use WireGuard for traffic between pods

Default: `"cilium-wireguard"`

Change after cluster initialization:
Existing CNI will not be uninstalled automatically.

## install_hcloud_ccm

Install [hcloud-ccm](https://github.com/hetznercloud/hcloud-cloud-controller-manager) in the cluster.

If enabled:

* hcloud-ccm will be installed in the cluster.
* hcloud-ccm will be configured to use the Hetzner Cloud API token also used by Terraform.
* hcloud-ccm will take care of assigning pod CIDRs, adding routes to Hetzner Cloud, initializing nodes, etc.

If disabled:

* hcloud-ccm will not be installed in the cluster.
* Terraform will assign pod CIDRs and add routes to Hetzner Cloud.
* Ansible will initialize each node and set pod CIDR, labels, remove uninitialized taint, etc.

Default: `false`

Change after cluster initialization:
Breaks cluster.

## install_hcloud_csi

Install hcloud-csi in cluster.

Default: `false`

Change after cluster initialization:
hcloud-csi will be installed when the setting is enabled,
but not uninstalled when the setting is disabled.

## install_cert_manager

Install cert-manager in cluster.

Default: `false`

Change after cluster initialization:
cert-manager will be installed when the setting is enabled,
but not uninstalled when the setting is disabled.

## install_ceph_client

Install Ceph client in cluster.

Default: `false`
Ceph client will be installed when the setting is enabled,
but not uninstalled when the setting is disabled.

## install_reloader

Install [Reloader](https://github.com/stakater/Reloader) in cluster.

Default: `false`
Reloader will be installed when the setting is enabled,
but not uninstalled when the setting is disabled.

## registry_mirrors

Container registry mirrors to use.

Example: `{"docker.io" : ["https://docker-io.container-registry-mirror.example.com", "https://registry-1.docker.io"]}`

Default: `{"docker.io" : ["https://registry-1.docker.io"]}`

Change after cluster initialization:
Should be safe. Restarts containerd.
