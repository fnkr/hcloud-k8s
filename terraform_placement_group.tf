variable "cluster_use_placement_group" {
  type    = bool
  default = true
}

variable "cluster_existing_placement_group_name" {
  type    = string
  default = ""
}

variable "cluster_placement_group_type" {
  type    = string
  default = "spread"
}

data "hcloud_placement_group" "placement_group" {
  count = var.cluster_use_placement_group ? 1 : 0
  name  = var.cluster_existing_placement_group_name == "" ? hcloud_placement_group.placement_group.0.name : var.cluster_existing_placement_group_name
}

resource "hcloud_placement_group" "placement_group" {
  count  = var.cluster_use_placement_group ? 1 : 0
  name   = var.cluster_name
  type   = var.cluster_placement_group_type
  labels = local.labels
}
