locals {
  managed_by = "Terraform"
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.cluster_name
  tags = {
    "Name"        = var.cluster_name
    "ManagedBy"   = local.managed_by
    "Environment" = var.environment
  }
}

resource "aws_ecs_capacity_provider" "capacity_providers" {
  for_each = { for name, capacity_provider in var.capacity_providers : capacity_provider.name => capacity_provider }
  name     = "${var.environment}_ecs_${each.value.name}"
  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs_cluster_asg[each.key].arn
    managed_scaling {
      target_capacity = each.value.target_capacity
      status          = each.value.managed_scaling_status
    }
    managed_termination_protection = each.value.managed_termination_protection
  }
  tags = {
    "ManagedBy" = local.managed_by
  }
  depends_on = [aws_autoscaling_group.ecs_cluster_asg]
}

resource "aws_ecs_cluster_capacity_providers" "ecs_cluster_capacity_provider" {
  cluster_name       = aws_ecs_cluster.ecs_cluster.name
  capacity_providers = [for cp in aws_ecs_capacity_provider.capacity_providers : cp.name]
  depends_on         = [aws_ecs_capacity_provider.capacity_providers]
}
