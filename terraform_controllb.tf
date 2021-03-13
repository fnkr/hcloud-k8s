resource "hcloud_load_balancer" "controllb" {
  name               = "${var.cluster_name}-control"
  load_balancer_type = var.cluster_controllb_type
  location           = var.cluster_controllb_location
  labels             = merge(local.labels, local.control_labels)

  algorithm {
    type = "least_connections"
  }
}

resource "hcloud_network_subnet" "network_subnet_controllb" {
  type         = "cloud"
  network_id   = hcloud_network.network.id
  network_zone = var.cluster_network_zone
  ip_range     = var.cluster_network_ip_range_controllb
}

resource "hcloud_load_balancer_network" "controllb_network" {
  load_balancer_id = hcloud_load_balancer.controllb.id
  network_id       = hcloud_network.network.id
  ip               = cidrhost(hcloud_network_subnet.network_subnet_controllb.ip_range, 1)
}

resource "hcloud_load_balancer_target" "controllb_target" {
  type             = "label_selector"
  load_balancer_id = hcloud_load_balancer.controllb.id
  label_selector   = "${var.cluster_label_key}=${var.cluster_name},${var.role_label_key}=${var.role_label_control},${var.status_label_key}=${var.status_label_up}"
  use_private_ip   = true

  depends_on = [
    hcloud_load_balancer_network.controllb_network
  ]
}

resource "hcloud_load_balancer_service" "controllb_service_https" {
  load_balancer_id = hcloud_load_balancer.controllb.id
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
