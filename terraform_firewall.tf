resource "hcloud_firewall" "nodefw" {
  name = "${var.cluster_name}-node"

  # Add fake rule to invert default policy from allow to drop
  rule {
    direction = "in"
    protocol  = "icmp"
    source_ips = [
      "0.0.0.0/32",
      "::/128"
    ]
  }

  # Allow access from this machine
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
}
