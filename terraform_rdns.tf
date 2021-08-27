resource "hcloud_rdns" "controlnode_ipv4" {
  count      = var.cluster_domain == "" ? 0 : length(hcloud_server.controlnode)
  server_id  = hcloud_server.controlnode[count.index].id
  ip_address = hcloud_server.controlnode[count.index].ipv4_address
  dns_ptr    = hcloud_server.controlnode[count.index].name
}

resource "hcloud_rdns" "controlnode_ipv6" {
  count      = var.cluster_domain == "" ? 0 : length(hcloud_server.controlnode)
  server_id  = hcloud_server.controlnode[count.index].id
  ip_address = hcloud_server.controlnode[count.index].ipv6_address
  dns_ptr    = hcloud_server.controlnode[count.index].name
}

resource "hcloud_rdns" "controllb_ipv4" {
  count            = var.cluster_domain == "" ? 0 : length(hcloud_load_balancer.controllb)
  load_balancer_id = hcloud_load_balancer.controllb[count.index].id
  ip_address       = hcloud_load_balancer.controllb[count.index].ipv4
  dns_ptr          = hcloud_load_balancer.controllb[count.index].name
}

resource "hcloud_rdns" "controllb_ipv6" {
  count            = var.cluster_domain == "" ? 0 : length(hcloud_load_balancer.controllb)
  load_balancer_id = hcloud_load_balancer.controllb[count.index].id
  ip_address       = hcloud_load_balancer.controllb[count.index].ipv6
  dns_ptr          = hcloud_load_balancer.controllb[count.index].name
}

resource "hcloud_rdns" "workernode_ipv4" {
  count      = var.cluster_domain == "" ? 0 : length(hcloud_server.workernode)
  server_id  = hcloud_server.workernode[count.index].id
  ip_address = hcloud_server.workernode[count.index].ipv4_address
  dns_ptr    = hcloud_server.workernode[count.index].name
}

resource "hcloud_rdns" "workernode_ipv6" {
  count      = var.cluster_domain == "" ? 0 : length(hcloud_server.workernode)
  server_id  = hcloud_server.workernode[count.index].id
  ip_address = hcloud_server.workernode[count.index].ipv6_address
  dns_ptr    = hcloud_server.workernode[count.index].name
}

resource "hcloud_rdns" "workerlb_ipv4" {
  count            = var.cluster_domain == "" ? 0 : length(hcloud_load_balancer.workerlb)
  load_balancer_id = hcloud_load_balancer.workerlb[count.index].id
  ip_address       = hcloud_load_balancer.workerlb[count.index].ipv4
  dns_ptr          = hcloud_load_balancer.workerlb[count.index].name
}

resource "hcloud_rdns" "workerlb_ipv6" {
  count            = var.cluster_domain == "" ? 0 : length(hcloud_load_balancer.workerlb)
  load_balancer_id = hcloud_load_balancer.workerlb[count.index].id
  ip_address       = hcloud_load_balancer.workerlb[count.index].ipv6
  dns_ptr          = hcloud_load_balancer.workerlb[count.index].name
}
