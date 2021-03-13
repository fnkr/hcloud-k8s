resource "hcloud_network" "network" {
  name     = var.cluster_name
  ip_range = var.cluster_network_ip_range
  labels   = local.labels
}
