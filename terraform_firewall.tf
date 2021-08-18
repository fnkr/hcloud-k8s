resource "hcloud_firewall" "nodefw" {
  name = "${var.cluster_name}-node"

  # Allow access from this machine only

  rule {
    direction  = "in"
    protocol   = "icmp"
    source_ips = ["${data.http.my_ip_v4_address.body}/32"]
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips = ["${data.http.my_ip_v4_address.body}/32"]
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "6443"
    source_ips = ["${data.http.my_ip_v4_address.body}/32"]
  }
}
