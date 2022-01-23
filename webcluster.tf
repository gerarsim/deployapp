resource "aws_ecs_cluster" "web-cluster" {
  name               = var.cluster_name
  capacity_providers = [aws_ecs_capacity_provider.capacity_driver.name]
  tags = {
    "env"       = "dev"
    "createdBy" = "Samir Merdoud"
  }
}

resource "aws_ecs_capacity_provider" "capacity_driver" {
  name = "capacity-provider"
  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.asg.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      status          = "ENABLED"
      target_capacity = 10
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 1000
    }
  }
}

# update file container-def, so it's pulling image from ecr
resource "aws_ecs_task_definition" "task-definition" {
  family                = "web-app"
  container_definitions = file("container-definitions/container-def.json")
  network_mode          = "bridge"
  tags = {
    "env"       = "dev"
    "createdBy" = "Samir Merdoud"
  }
}

resource "aws_ecs_service" "service" {
  name            = "web-service"
  cluster         = aws_ecs_cluster.web-cluster.id
  task_definition = aws_ecs_task_definition.task-definition.arn
  desired_count   = 10
  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = "containersami"
    container_port   = 80
  }
  # Optional: Allow external changes without Terraform plan difference(for example ASG)
  lifecycle {
    ignore_changes = [desired_count]
  }
  launch_type = "EC2"
  depends_on  = [aws_lb_listener.web-listener]
}

resource "aws_cloudwatch_log_group" "logging" {
  name = "/ecs/frontend-container"
  tags = {
    "env"       = "dev"
    "createdBy" = "Samir Merdoud"
  }
}