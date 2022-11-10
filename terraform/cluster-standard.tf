resource "ibm_container_vpc_cluster" "cluster_std" {
  name                            = format("%s-%s", var.environment_id, var.cluster_name_std)
  vpc_id                          = ibm_is_vpc.vpc.id
  flavor                          = var.machine_type
  worker_count                    = var.worker_count
  resource_group_id               = ibm_resource_group.resource_group.id
  update_all_workers              = true
  disable_public_service_endpoint = false
  kube_version                    = var.kube_version

  dynamic "zones" {
    for_each = { for subnet in ibm_is_subnet.subnet : subnet.id => subnet }
    content {
      name      = zones.value.zone
      subnet_id = zones.value.id
    }
  }

  entitlement = var.entitlement
  tags        = var.tags
}