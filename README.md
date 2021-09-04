# hcloud-k8s

This repository contains a Terraform module and Ansible playbook to provision
[Kubernetes](https://kubernetes.io) clusters on [Hetzner Cloud](https://hetzner.cloud).

## Features

* High availability: creates three control nodes and three worker nodes
* etcd stacked on control plane nodes
* containerd container runtime
* Installs [Hetzner Cloud Controller Manager](https://github.com/hetznercloud/hcloud-cloud-controller-manager)
* Installs [Hetzner Cloud Container Storage Interface](https://github.com/hetznercloud/csi-driver)
* Uses placement groups to spread servers across a datacenter
* Uses Hetzner Cloud Networks for all traffic between nodes
* Uses Cilium with native routing through Hetzner Cloud Networks
* Uses Cilium's WireGuard integration to encrypt traffic between pods
* Creates Hetzner Cloud Load Balancer for traffic to K8s API
* Creates Hetzner Cloud Load Balancer for traffic to worker nodes (ingress)
* Creates Hetzner Cloud Firewall to restrict inbound traffic to servers
* Installs [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/) as DaemonSet
* Installs [cert-manager](https://cert-manager.io/)
* Installs Ceph client

Many features are optional, customizable and might be turned on or off by default.
See [VARIABLES.md](VARIABLES.md) for details.

## Prerequisites

Instructions should work on Linux and macOS.
I suggest using the Subsystem for Linux (WSL2) on Windows.
Make sure the following tools are installed before proceeding:

* Terraform
* Ansible
* kubectl

## Backwards compatibility

This project is in early development. It works, but there is still a lot to do. 
Each commit in the main branch is potentially breaking (might requires recreating the cluster).
As soon as there is a stable version, it will be tagged `v1.0.0`.
Tags should then be non-breaking until the next major version bump (`v2.0.0`).

## Getting started

**1)** Generate Read & Write API token

Open Hetzner Cloud Console > Select Project > Security > API tokens > Generate API token

Note that the cluster will continue using this API token, even after Terraform and Ansible is done.
If the API token is deleted from Hetzner Cloud, the cluster will stop functioning.

**2)** Add your SSH key

Open Hetzner Cloud Console > Select Project > Security > SSH keys > Add SSH key

Terraform and Ansible will use this key to connect to servers.
Make sure that the key is available on your local machine and loaded in ssh-agent (if the key is encrypted).

**3)** Copy example configuration

```
cp terraform.tfvars.example terraform.tfvars
```

Change at least the following values:

`hcloud_token`: Hetzner Cloud API token created during step 1  
`cluster_authorized_ssh_keys`: Name of the SSH key added to Hetzner Cloud during step 2

Turn on/off features, customize topology, ..., e.g.:

```hcl
install_hcloud_ccm   = true
install_hcloud_csi   = true
install_ceph_client  = true
install_cert_manager = true
```

See [VARIABLES.md](VARIABLES.md) for details.

**4)** Provision K8s cluster

```
terraform init
terraform apply -auto-approve
ansible-playbook ansible.yaml
```

**5)** Update kube client configuration

This will add the cluster to your local `~/.kube/config`.

```
ansible-playbook kubeconfig.yaml
```

Test if connection works. Replace `testkube` with the `cluster_name` of your cluster.

```
kubectl --context testkube get all --all-namespaces
```

**6)** Watch your new cluster

It might take a minute until all pods are up.

```
watch kubectl get all --all-namespaces
```

**7)** Delete your cluster

You can use this command to destroy your cluster.
It will delete all servers, load balancers and networks created by Terraform.
It will not delete anything created by Kubernetes (e.g. volumes created using persistent volume claims).

```
terraform destroy -auto-approve
```

Destroy cluster without destroying the infrastructure (factory-reset all servers):

```bash
export HCLOUD_TOKEN="$(grep ^hcloud_token terraform.tfvars | awk -F '"' '{print $2}')"
hcloud server list -o noheader -o columns=name | grep ^testkube- | xargs -n 1 hcloud server rebuild --image=ubuntu-20.04
```

## Working with multiple state/var files

```
terraform apply -var-file production.tfvars -state production.tfstate
TF_STATE=production.tfstate ansible-playbook ansible.yaml
TF_STATE=production.tfstate ansible-playbook kubeconfig.yaml
```

## Minimal cluster

By default, a cluster with multiple control nodes, worker nodes and load balancers will be created.
If you just want a simple (non-HA) cluster for development/testing,
you can remove any additional servers and load balancers:

```hcl
cluster_controlnode_types     = ["cx21"]
cluster_controlnode_locations = ["nbg1"]
cluster_workernode_types      = []
cluster_workernode_locations  = []
cluster_controllb_types       = []
cluster_controllb_locations   = []
cluster_workerlb_types        = []
cluster_workerlb_locations    = []
```

* If there are no worker nodes, the master taint will be removed from control nodes automatically,
  so they can be used as worker nodes. (Not recommended for production.)
* If there are no control node load balancers, the IP from the first control node in the same location,
  or the first one if none exists in the same location, will be used.
  (Breaks high availability, not recommended for production.)
