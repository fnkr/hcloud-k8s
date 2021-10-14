variable "hcloud_token" {
  type    = string
  default = null
}

variable "cluster_name" {
  type    = string
  default = "testkube"
}

variable "cluster_domain" {
  type    = string
  default = ""
}

variable "cluster_ingress" {
  type    = string
  default = "nginx"
}

variable "cluster_cni" {
  type    = string
  default = "cilium-wireguard"
}

variable "registry_mirrors" {
  type = map(list(string))

  default = {
    "docker.io" : ["https://registry-1.docker.io"]
  }
}

variable "install_hcloud_ccm" {
  type    = bool
  default = false
}

variable "install_hcloud_csi" {
  type    = bool
  default = false
}

variable "install_cert_manager" {
  type    = bool
  default = false
}

variable "install_ceph_client" {
  type    = bool
  default = false
}

variable "install_reloader" {
  type    = bool
  default = false
}

variable "cluster_authorized_ssh_keys" {
  type = list(string)
}

variable "cluster_node_image" {
  type    = string
  default = "ubuntu-20.04"
}

variable "k8s_version" {
  type    = string
  default = "1.21.4"
}

variable "k8s_version_label_key" {
  type    = string
  default = "k8s_version"
}

variable "cluster_label_key" {
  type    = string
  default = "k8s_cluster"
}

variable "role_label_key" {
  type    = string
  default = "k8s_role"
}

variable "role_label_control" {
  type    = string
  default = "control"
}

variable "role_label_worker" {
  type    = string
  default = "worker"
}

variable "initializer_label_key" {
  type    = string
  default = "k8s_initializer"
}

variable "initializer_label_value" {
  type    = string
  default = "1"
}

variable "status_label_key" {
  type    = string
  default = "k8s_status"
}

variable "status_label_up" {
  type    = string
  default = "up"
}
