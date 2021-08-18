variable "cluster_existing_network_name" {
  type    = string
  default = ""
}

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
  default = "10.9.0.0/16"
}

variable "cluster_network_ip_range_pod" {
  type    = string
  default = "10.10.0.0/15"
}

data "hcloud_network" "network" {
  name = var.cluster_existing_network_name == "" ? hcloud_network.network.0.name : var.cluster_existing_network_name
}

resource "hcloud_network" "network" {
  count    = var.cluster_existing_network_name == "" ? 1 : 0
  name     = var.cluster_name
  ip_range = var.cluster_network_ip_range
  labels   = local.labels
}
