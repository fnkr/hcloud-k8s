provider "hcloud" {
  token = var.hcloud_token
}

variable "hcloud_token" {}
variable "cluster_authorized_ssh_keys" {}
variable "cluster_name" {}
variable "cluster_node_count" {}
variable "cluster_node_types" {}
variable "cluster_node_locations" {}
variable "cluster_network_zone" {}
variable "cluster_network_ip_range" {}
variable "cluster_network_ip_range_node" {}
variable "cluster_network_ip_range_loadbalancer" {}
variable "cluster_loadbalancer_type" {}
variable "cluster_loadbalancer_location" {}

variable "cluster_node_image" {
  type    = string
  default = "ubuntu-20.04"
}

variable "cluster_node_label_name" {
  type    = string
  default = "k8s"
}

resource "hcloud_network" "network" {
  name     = var.cluster_name
  ip_range = var.cluster_network_ip_range
}

resource "hcloud_network_subnet" "network_subnet_node" {
  type         = "cloud"
  network_id   = hcloud_network.network.id
  network_zone = "eu-central"
  ip_range     = var.cluster_network_ip_range_node
}

resource "hcloud_network_subnet" "network_subnet_loadbalancer" {
  type         = "cloud"
  network_id   = hcloud_network.network.id
  network_zone = "eu-central"
  ip_range     = var.cluster_network_ip_range_loadbalancer
}

resource "hcloud_server" "node" {
  count       = var.cluster_node_count
  name        = "${var.cluster_name}-node-${count.index + 1}"
  image       = var.cluster_node_image
  server_type = split(",", var.cluster_node_types)[count.index]
  location    = split(",", var.cluster_node_locations)[count.index]
  ssh_keys    = split(",", var.cluster_authorized_ssh_keys)
  labels      = { "${var.cluster_node_label_name}" : var.cluster_name }

  connection {
    type = "ssh"
    user = "root"
    host = self.ipv4_address
  }

  #provisioner "remote-exec" {
  #  inline = [
  #    "ufw allow ssh",
  #    "ufw allow from ${var.cluster_network_ip_range}",
  #    "ufw default deny incoming",
  #    "ufw default allow outgoing",
  #    "ufw --force enable"
  #  ]
  #}
}

resource "hcloud_server_network" "node_network" {
  count      = var.cluster_node_count
  server_id  = hcloud_server.node[count.index].id
  network_id = hcloud_network.network.id
  ip         = cidrhost(var.cluster_network_ip_range_node, count.index + 1)
}

resource "hcloud_load_balancer" "loadbalancer" {
  name               = var.cluster_name
  load_balancer_type = var.cluster_loadbalancer_type
  location           = var.cluster_loadbalancer_location

  algorithm {
    type = "least_connections"
  }
}

resource "hcloud_load_balancer_network" "loadbalancer_network" {
  load_balancer_id = hcloud_load_balancer.loadbalancer.id
  network_id       = hcloud_network.network.id
  ip               = cidrhost(var.cluster_network_ip_range_loadbalancer, 1)
}

resource "hcloud_load_balancer_target" "loadbalancer_target" {
  type             = "label_selector"
  load_balancer_id = hcloud_load_balancer.loadbalancer.id
  label_selector   = "${var.cluster_node_label_name}=${var.cluster_name}"
  use_private_ip   = true
}

resource "hcloud_load_balancer_service" "loadbalancer_service_http" {
  load_balancer_id = hcloud_load_balancer.loadbalancer.id
  protocol         = "tcp"
  listen_port      = 80
  destination_port = 80
}

resource "hcloud_load_balancer_service" "loadbalancer_service_https" {
  load_balancer_id = hcloud_load_balancer.loadbalancer.id
  protocol         = "tcp"
  listen_port      = 443
  destination_port = 443
}

output "node_names" {
  value = hcloud_server.node.*.name
}

output "node_ipv4_addresses" {
  value = hcloud_server.node.*.ipv4_address
}

output "cluster_network_ip_range" {
  value = var.cluster_network_ip_range
}
