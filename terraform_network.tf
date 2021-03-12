resource "hcloud_network" "network" {
  name     = var.cluster_name
  ip_range = var.cluster_network_ip_range
  labels   = local.labels
}

resource "hcloud_network_subnet" "network_subnet_loadbalancer" {
  type         = "cloud"
  network_id   = hcloud_network.network.id
  network_zone = var.cluster_network_zone
  ip_range     = var.cluster_network_ip_range_loadbalancer
}
