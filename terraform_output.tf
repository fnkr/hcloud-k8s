output "hcloud_token" {
  value     = var.hcloud_token
  sensitive = true
}

output "cluster_name" {
  value = var.cluster_name
}

output "k8s_version" {
  value = var.k8s_version
}

output "initializer" {
  value = [for k, v in hcloud_server.controlnode.*.labels : hcloud_server.controlnode[k].name if try(v[var.initializer_label_key], null) == var.initializer_label_value][0]
}

output "controlnode_names" {
  value = hcloud_server.controlnode.*.name
}

output "workernode_names" {
  value = hcloud_server.workernode.*.name
}

output "controlnode_ipv4_addresses" {
  value = hcloud_server.controlnode.*.ipv4_address
}

output "workernode_ipv4_addresses" {
  value = hcloud_server.workernode.*.ipv4_address
}

output "cluster_network_ip_range" {
  value = var.cluster_network_ip_range
}

output "cluster_network_ip_range_controlnode" {
  value = var.cluster_network_ip_range_controlnode
}

output "cluster_network_ip_range_workernode" {
  value = var.cluster_network_ip_range_workernode
}

output "cluster_network_ip_range_service" {
  value = var.cluster_network_ip_range_service
}

output "cluster_network_ip_range_pod" {
  value = var.cluster_network_ip_range_pod
}

output "controllb_ipv4_address" {
  value = hcloud_load_balancer.controllb[0].ipv4
}

output "controllb_k8s_endpoint" {
  value = "${hcloud_load_balancer.controllb[0].ipv4}:${hcloud_load_balancer_service.controllb_service_https[0].listen_port}"
}

output "controllb_private_k8s_endpoint_port" {
  value = hcloud_load_balancer_service.controllb_service_https[0].listen_port
}

output "controllb_private_k8s_endpoint_ips_for_controlnodes" {
  value = [
    for location in var.cluster_controlnode_locations : hcloud_load_balancer_network.controllb_network[try(index(var.cluster_controllb_locations, location), 0)].ip
  ]
}

output "controllb_private_k8s_endpoint_ips_for_workernodes" {
  value = [
    for location in var.cluster_workernode_locations : hcloud_load_balancer_network.controllb_network[try(index(var.cluster_controllb_locations, location), 0)].ip
  ]
}

output "cluster_ingress" {
  value = var.cluster_ingress
}

output "cluster_cni" {
  value = var.cluster_cni
}

output "registry_mirrors" {
  value = var.registry_mirrors
}
