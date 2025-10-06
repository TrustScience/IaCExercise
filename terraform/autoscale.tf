# Target the ECS service desired count
resource "aws_appautoscaling_target" "iac_exercise_svc" {
  max_capacity       = 10
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.iac_exercise_cluster.name}/${aws_ecs_service.iac_exercise_app_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# Scale out on average CPU > 60%
resource "aws_appautoscaling_policy" "iac_exercise_cpu_scale_out" {
  name               = "${var.project}-cpu-scale-out"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.iac_exercise_svc.resource_id
  scalable_dimension = aws_appautoscaling_target.iac_exercise_svc.scalable_dimension
  service_namespace  = aws_appautoscaling_target.iac_exercise_svc.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 60
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

# Scale out on average Memory > 70%
resource "aws_appautoscaling_policy" "iac_exercise_mem_scale_out" {
  name               = "${var.project}-mem-scale-out"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.iac_exercise_svc.resource_id
  scalable_dimension = aws_appautoscaling_target.iac_exercise_svc.scalable_dimension
  service_namespace  = aws_appautoscaling_target.iac_exercise_svc.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value       = 70
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}
