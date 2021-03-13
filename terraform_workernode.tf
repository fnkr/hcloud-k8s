locals {
  cluster_workernode_count = length(split(",", var.cluster_workernode_types))
}

resource "hcloud_server" "workernode" {
  count       = local.cluster_workernode_count
  name        = "${var.cluster_name}-worker-${format("%03d", count.index + 1)}"
  image       = var.cluster_node_image
  server_type = split(",", var.cluster_workernode_types)[count.index]
  location    = split(",", var.cluster_workernode_locations)[count.index]
  ssh_keys    = split(",", var.cluster_authorized_ssh_keys)
  labels      = merge(local.labels, local.worker_labels, local.node_labels)

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

resource "hcloud_network_subnet" "network_subnet_workernode" {
  type         = "cloud"
  network_id   = hcloud_network.network.id
  network_zone = var.cluster_network_zone
  ip_range     = var.cluster_network_ip_range_workernode
}

resource "hcloud_server_network" "workernode_network" {
  count      = local.cluster_workernode_count
  server_id  = hcloud_server.workernode[count.index].id
  network_id = hcloud_network.network.id
  ip         = cidrhost(hcloud_network_subnet.network_subnet_workernode.ip_range, count.index + 1)
}
