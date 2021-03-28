variable "cluster_network_zone" {
  type    = string
  default = "eu-central"
}

variable "cluster_network_ip_range" {
  type    = string
  default = "10.8.0.0/14"
}

variable "cluster_network_ip_range_service" {
  type    = string
  default = "10.10.0.0/16"
}

variable "cluster_network_ip_range_pod" {
  type    = string
  default = "10.11.0.0/16"
}

resource "hcloud_network" "network" {
  name     = var.cluster_name
  ip_range = var.cluster_network_ip_range
  labels   = local.labels
}
