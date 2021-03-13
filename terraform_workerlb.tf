resource "hcloud_load_balancer" "workerlb" {
  name               = "${var.cluster_name}-worker"
  load_balancer_type = var.cluster_workerlb_type
  location           = var.cluster_workerlb_location
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
  load_balancer_id = hcloud_load_balancer.workerlb.id
  network_id       = hcloud_network.network.id
  ip               = cidrhost(hcloud_network_subnet.network_subnet_workerlb.ip_range, 1)
}

resource "hcloud_load_balancer_target" "workerlb_target" {
  type             = "label_selector"
  load_balancer_id = hcloud_load_balancer.workerlb.id
  label_selector   = "${var.cluster_label_key}=${var.cluster_name},${var.role_label_key}=${var.role_label_worker},${var.status_label_key}=${var.status_label_up}"
  use_private_ip   = true

  depends_on = [
    hcloud_load_balancer_network.workerlb_network
  ]
}

resource "hcloud_load_balancer_service" "workerlb_service_http" {
  load_balancer_id = hcloud_load_balancer.workerlb.id
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
  load_balancer_id = hcloud_load_balancer.workerlb.id
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
