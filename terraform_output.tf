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

output "controlnode_private_ipv4_addresses" {
  value = hcloud_server_network.controlnode_network.*.ip
}

output "workernode_ipv4_addresses" {
  value = hcloud_server.workernode.*.ipv4_address
}

output "workernode_private_ipv4_addresses" {
  value = hcloud_server_network.workernode_network.*.ip
}

output "controlnode_instance_types" {
  value = hcloud_server.controlnode.*.server_type
}

output "workernode_instance_types" {
  value = hcloud_server.workernode.*.server_type
}

output "controlnode_regions" {
  value = hcloud_server.controlnode.*.location
}

output "workernode_regions" {
  value = hcloud_server.workernode.*.location
}

output "controlnode_zones" {
  value = hcloud_server.controlnode.*.datacenter
}

output "workernode_zones" {
  value = hcloud_server.workernode.*.datacenter
}

output "cluster_network_id" {
  value = data.hcloud_network.network.id
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

output "cluster_network_ip_range_controlnode_pod" {
  value = hcloud_network_route.controlnode_pods.*.destination
}

output "cluster_network_ip_range_workernode_pod" {
  value = hcloud_network_route.workernode_pods.*.destination
}

output "controllb_ipv4_addresses" {
  value = length(hcloud_load_balancer.controllb) > 0 ? hcloud_load_balancer.controllb.*.ipv4 : hcloud_server.controlnode.*.ipv4_address
}

output "controllb_ipv6_addresses" {
  value = length(hcloud_load_balancer.controllb) > 0 ? hcloud_load_balancer.controllb.*.ipv6 : hcloud_server.controlnode.*.ipv6_address
}

output "controllb_private_ipv4_addresses" {
  value = length(hcloud_load_balancer.controllb) > 0 ? hcloud_load_balancer_network.controllb_network.*.ip : hcloud_server_network.controlnode_network.*.ip
}

output "controllb_k8s_endpoint" {
  value = "${length(hcloud_load_balancer.controllb) > 0 && !var.cluster_controllb_disable_public_network ? hcloud_load_balancer.controllb[0].ipv4 : hcloud_server.controlnode[0].ipv4_address}:${length(hcloud_load_balancer.controllb) > 0 && !var.cluster_controllb_disable_public_network ? hcloud_load_balancer_service.controllb_service_https[0].listen_port : 6443}"
}

output "controllb_private_k8s_endpoint_port" {
  value = length(hcloud_load_balancer.controllb) > 0 ? hcloud_load_balancer_service.controllb_service_https[0].listen_port : 6443
}

output "controllb_private_k8s_endpoint_ips_for_controlnodes" {
  value = length(hcloud_load_balancer.controllb) > 0 ? [
    for location in var.cluster_controlnode_locations : hcloud_load_balancer_network.controllb_network[try(index(var.cluster_controllb_locations, location), 0)].ip
    ] : [
    for location in var.cluster_controlnode_locations : hcloud_server_network.controlnode_network[try(index(var.cluster_controlnode_locations, location), 0)].ip
  ]
}

output "controllb_private_k8s_endpoint_ips_for_workernodes" {
  value = length(hcloud_load_balancer.controllb) > 0 ? [
    for location in var.cluster_workernode_locations : hcloud_load_balancer_network.controllb_network[try(index(var.cluster_controllb_locations, location), 0)].ip
    ] : [
    for location in var.cluster_workernode_locations : hcloud_server_network.controlnode_network[try(index(var.cluster_controlnode_locations, location), 0)].ip
  ]
}

output "cluster_ingress" {
  value = var.cluster_ingress
}

output "cluster_ingress_proxy_protocol" {
  value = length(hcloud_load_balancer.workerlb) > 0
}

output "cluster_cni" {
  value = var.cluster_cni
}

output "registry_mirrors" {
  value = var.registry_mirrors
}

output "install_hcloud_ccm" {
  value = var.install_hcloud_ccm
}

output "install_hcloud_csi" {
  value = var.install_hcloud_csi
}

output "install_cert_manager" {
  value = var.install_cert_manager
}

output "install_ceph_client" {
  value = var.install_ceph_client
}

output "install_reloader" {
  value = var.install_reloader
}
