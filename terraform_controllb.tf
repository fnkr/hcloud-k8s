variable "cluster_controllb_types" {
  type    = list(string)
  default = ["lb11", "lb11", "lb11"]
}

variable "cluster_controllb_locations" {
  type    = list(string)
  default = ["nbg1", "fsn1", "hel1"]
}

variable "cluster_controllb_disable_public_network" {
  type    = bool
  default = false
}

variable "cluster_network_ip_range_controllb" {
  type    = string
  default = "10.8.2.0/24"
}

locals {
  cluster_controllb_count = length(var.cluster_controllb_types)
}

resource "hcloud_load_balancer" "controllb" {
  count              = local.cluster_controllb_count
  name               = format(local.cluster_resource_name, local.cluster_resource_name_controllb, count.index + 1)
  load_balancer_type = var.cluster_controllb_types[count.index]
  location           = var.cluster_controllb_locations[count.index]
  labels             = merge(local.labels, local.control_labels)

  algorithm {
    type = "least_connections"
  }
}

resource "hcloud_network_subnet" "network_subnet_controllb" {
  type         = "cloud"
  network_id   = data.hcloud_network.network.id
  network_zone = var.cluster_network_zone
  ip_range     = var.cluster_network_ip_range_controllb
}

resource "hcloud_load_balancer_network" "controllb_network" {
  count                   = local.cluster_controllb_count
  load_balancer_id        = hcloud_load_balancer.controllb[count.index].id
  network_id              = data.hcloud_network.network.id
  ip                      = cidrhost(hcloud_network_subnet.network_subnet_controllb.ip_range, count.index + 1)
  enable_public_interface = !var.cluster_controllb_disable_public_network
}

resource "hcloud_load_balancer_target" "controllb_target" {
  count            = local.cluster_controllb_count
  type             = "label_selector"
  load_balancer_id = hcloud_load_balancer.controllb[count.index].id
  label_selector   = "${var.cluster_label_key}=${var.cluster_name},${var.role_label_key}=${var.role_label_control},${var.status_label_key}=${var.status_label_up}"
  use_private_ip   = true

  depends_on = [
    hcloud_load_balancer_network.controllb_network
  ]
}

resource "hcloud_load_balancer_service" "controllb_service_https" {
  count            = local.cluster_controllb_count
  load_balancer_id = hcloud_load_balancer.controllb[count.index].id
  protocol         = "tcp"
  listen_port      = 6443
  destination_port = 6443

  health_check {
    protocol = "http"
    port     = 6443
    interval = 10
    timeout  = 5
    retries  = 3
    http {
      tls          = true
      path         = "/readyz"
      response     = "ok"
      status_codes = ["200"]
    }
  }
}
