variable "cluster_controlnode_types" {
  type    = list(string)
  default = ["cx21", "cx21", "cx21"]
}

variable "cluster_controlnode_locations" {
  type    = list(string)
  default = ["nbg1", "fsn1", "hel1"]
}

variable "cluster_network_ip_range_controlnode" {
  type    = string
  default = "10.8.10.0/24"
}

locals {
  cluster_controlnode_count = length(var.cluster_controlnode_types)
}

resource "hcloud_server" "controlnode" {
  count              = local.cluster_controlnode_count
  name               = format(local.cluster_resource_name, local.cluster_resource_name_controlnode, count.index + 1)
  image              = var.cluster_node_image
  server_type        = var.cluster_controlnode_types[count.index]
  location           = var.cluster_controlnode_locations[count.index]
  placement_group_id = var.cluster_use_placement_group ? hcloud_placement_group.placement_group.0.id : null
  ssh_keys           = var.cluster_authorized_ssh_keys
  labels             = merge(local.labels, local.control_labels, local.node_labels, count.index == 0 ? local.initializer_labels : null)

  firewall_ids = [
    hcloud_firewall.nodefw.id
  ]
}

resource "hcloud_network_subnet" "network_subnet_controlnode" {
  type         = "cloud"
  network_id   = data.hcloud_network.network.id
  network_zone = var.cluster_network_zone
  ip_range     = var.cluster_network_ip_range_controlnode
}

resource "hcloud_server_network" "controlnode_network" {
  count      = local.cluster_controlnode_count
  server_id  = hcloud_server.controlnode[count.index].id
  network_id = data.hcloud_network.network.id
  ip         = cidrhost(hcloud_network_subnet.network_subnet_controlnode.ip_range, count.index + 1)
}

resource "hcloud_network_route" "controlnode_pods" {
  count       = var.install_hcloud_ccm ? 0 : local.cluster_controlnode_count
  network_id  = data.hcloud_network.network.id
  destination = cidrsubnet(cidrsubnet(var.cluster_network_ip_range_pod, 1, 0), 8, count.index + 1)
  gateway     = hcloud_server_network.controlnode_network[count.index].ip
}
