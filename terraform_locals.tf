locals {
  labels = {
    (var.cluster_label_key) : var.cluster_name,
  }

  control_labels = {
    (var.role_label_key) : var.role_label_control,
  }

  worker_labels = {
    (var.role_label_key) : var.role_label_worker,
  }

  node_labels = {
    (var.k8s_version_label_key) : var.k8s_version,
    (var.status_label_key) : var.status_label_up,
  }

  initializer_labels = {
    (var.initializer_label_key) : var.initializer_label_value,
  }

  cluster_resource_number_format = "%03d"
  cluster_resource_name_short    = "${var.cluster_name}-%s-${local.cluster_resource_number_format}"
  cluster_resource_name_fqdn     = "%s-${local.cluster_resource_number_format}.${var.cluster_domain}"
  cluster_resource_name          = var.cluster_domain == "" ? local.cluster_resource_name_short : local.cluster_resource_name_fqdn

  cluster_resource_name_controlnode = var.cluster_domain == "" ? "control" : "controlnode"
  cluster_resource_name_controllb   = var.cluster_domain == "" ? "control" : "controllb"
  cluster_resource_name_workernode  = var.cluster_domain == "" ? "worker" : "workernode"
  cluster_resource_name_workerlb    = var.cluster_domain == "" ? "worker" : "workerlb"
}
