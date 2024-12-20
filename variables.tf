variable "environment" {
  type        = string
  description = "Environment. Example: staging, production."
}
variable "cluster_name" {
  type        = string
  description = "Name of ECS cluster."
}
variable "capacity_providers" {
  type = list(object({
    name                           = string
    target_capacity                = number
    managed_scaling_status         = string
    managed_termination_protection = string
  }))
  description = "Capacity provider configuration."
}
variable "asg" {
  type = list(object({
    name                      = string
    vpc_zone_identifier       = list(string)
    health_check_type         = string
    health_check_grace_period = number
    max_size                  = number
    min_size                  = number
    protect_from_scale_in     = bool
    additional_tags = list(object({
      key                 = string
      value               = string
      propagate_at_launch = bool
    }))
  }))
  description = "Autoscaling group configuration."
}

variable "launch_configs" {
  type = list(object({
    name                      = string
    image_id                  = string
    instance_type             = string
    user_data_base64          = string
    iam_instance_profile_name = string
    root_block_device = object({
      volume_type = string
      volume_size = number
    })
    security_group_ids = list(string)
    metadata_options = object({
      http_endpoint               = string
      http_put_response_hop_limit = number
      http_tokens                 = string
    })
  }))
  description = "Launch configuration for EC2 instances."
}
