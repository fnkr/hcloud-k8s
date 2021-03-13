variable "cluster_controlnode_types" {
  type = list(string)
}

variable "cluster_controlnode_locations" {
  type = list(string)
}

locals {
  cluster_controlnode_count = length(var.cluster_controlnode_types)
}

resource "hcloud_server" "controlnode" {
  count       = local.cluster_controlnode_count
  name        = "${var.cluster_name}-control-${format("%03d", count.index + 1)}"
  image       = var.cluster_node_image
  server_type = var.cluster_controlnode_types[count.index]
  location    = var.cluster_controlnode_locations[count.index]
  ssh_keys    = var.cluster_authorized_ssh_keys
  labels      = merge(local.labels, local.control_labels, local.node_labels, count.index == 0 ? local.initializer_labels : null)

  firewall_ids = [
    hcloud_firewall.nodefw.id
  ]

  connection {
    type = "ssh"
    user = "root"
    host = self.ipv4_address
  }

  provisioner "remote-exec" {
    inline = [
      # Use Hetzner mirror instead of the official mirrors (faster downloads)
      "echo > /etc/apt/sources.list",
    ]
  }
}

resource "hcloud_network_subnet" "network_subnet_controlnode" {
  type         = "cloud"
  network_id   = hcloud_network.network.id
  network_zone = var.cluster_network_zone
  ip_range     = var.cluster_network_ip_range_controlnode
}

resource "hcloud_server_network" "controlnode_network" {
  count      = local.cluster_controlnode_count
  server_id  = hcloud_server.controlnode[count.index].id
  network_id = hcloud_network.network.id
  ip         = cidrhost(hcloud_network_subnet.network_subnet_controlnode.ip_range, count.index + 1)
}
