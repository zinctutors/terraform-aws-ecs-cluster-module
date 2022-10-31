resource "aws_launch_configuration" "ecs_launch_config" {
  for_each             = { for launch_config_name, launch_config in var.launch_configs : launch_config.name => launch_config }
  name_prefix          = "${var.environment}_ecs_${each.value.name}_"
  image_id             = each.value.image_id
  instance_type        = each.value.instance_type
  user_data_base64     = each.value.user_data_base64
  iam_instance_profile = each.value.iam_instance_profile_name

  dynamic "root_block_device" {
    for_each = each.value.root_block_device != null ? [each.value.root_block_device] : []

    content {
      volume_type = root_block_device.value.volume_type
      volume_size = root_block_device.value.volume_size
    }
  }
  security_groups = each.value.security_group_ids
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ecs_cluster_asg" {
  for_each                  = { for asg_name, asg in var.asg : asg.name => asg }
  name                      = "${var.environment}_ecs_${each.value.name}"
  vpc_zone_identifier       = each.value.vpc_zone_identifier
  health_check_type         = each.value.health_check_type
  health_check_grace_period = each.value.health_check_grace_period
  launch_configuration      = aws_launch_configuration.ecs_launch_config[each.key].name
  max_size                  = each.value.max_size
  min_size                  = each.value.min_size
  protect_from_scale_in     = each.value.protect_from_scale_in
  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "${var.environment}_ecs_${each.value.name}"
  }
  tag {
    key                 = "ManagedBy"
    propagate_at_launch = false
    value               = local.managed_by
  }
  tag {
    key                 = "Environment"
    propagate_at_launch = true
    value               = var.environment
  }
  dynamic "tag" {
    for_each = each.value.additional_tags
    content {
      key                 = tag.value.key
      value               = tag.value.value
      propagate_at_launch = tag.value.propagate_at_launch
    }
  }
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [aws_launch_configuration.ecs_launch_config]
}
