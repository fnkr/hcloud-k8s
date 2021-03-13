variable "cluster_workerlb_types" {}
variable "cluster_workerlb_locations" {}

locals {
  cluster_workerlb_count = length(split(",", var.cluster_workerlb_types))
}

resource "hcloud_load_balancer" "workerlb" {
  count              = local.cluster_workerlb_count
  name               = "${var.cluster_name}-worker-${format("%03d", count.index + 1)}"
  load_balancer_type = split(",", var.cluster_workerlb_types)[count.index]
  location           = split(",", var.cluster_workerlb_locations)[count.index]
  labels             = merge(local.labels, local.worker_labels)

  algorithm {
    type = "least_connections"
  }
}

resource "hcloud_network_subnet" "network_subnet_workerlb" {
  type         = "cloud"
  network_id   = hcloud_network.network.id
  network_zone = var.cluster_network_zone
  ip_range     = var.cluster_network_ip_range_workerlb
}

resource "hcloud_load_balancer_network" "workerlb_network" {
  count            = local.cluster_workerlb_count
  load_balancer_id = hcloud_load_balancer.workerlb[count.index].id
  network_id       = hcloud_network.network.id
  ip               = cidrhost(hcloud_network_subnet.network_subnet_workerlb.ip_range, count.index + 1)
}

resource "hcloud_load_balancer_target" "workerlb_target" {
  count            = local.cluster_workerlb_count
  type             = "label_selector"
  load_balancer_id = hcloud_load_balancer.workerlb[count.index].id
  label_selector   = "${var.cluster_label_key}=${var.cluster_name},${var.role_label_key}=${var.role_label_worker},${var.status_label_key}=${var.status_label_up}"
  use_private_ip   = true

  depends_on = [
    hcloud_load_balancer_network.workerlb_network
  ]
}

resource "hcloud_load_balancer_service" "workerlb_service_http" {
  count            = local.cluster_workerlb_count
  load_balancer_id = hcloud_load_balancer.workerlb[count.index].id
  protocol         = "tcp"
  listen_port      = 80
  destination_port = 80
  proxyprotocol    = true

  health_check {
    protocol = "tcp"
    port     = 80
    interval = 10
    timeout  = 5
    retries  = 3
  }
}

resource "hcloud_load_balancer_service" "workerlb_service_https" {
  count            = local.cluster_workerlb_count
  load_balancer_id = hcloud_load_balancer.workerlb[count.index].id
  protocol         = "tcp"
  listen_port      = 443
  destination_port = 443
  proxyprotocol    = true

  health_check {
    protocol = "tcp"
    port     = 443
    interval = 10
    timeout  = 5
    retries  = 3
  }
}
