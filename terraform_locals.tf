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
}
