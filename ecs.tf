locals {
    ecr_name = "${local.common_tags.service_initial_name}-ecr"
    ecr_base_url = "231272553907.dkr.ecr.ap-south-1.amazonaws.com/${local.ecr_name}:latest"
}

# Create ECS cluster
resource "aws_ecs_cluster" "main" {
  name = "${local.common_tags.service_initial_name}-ecs-cluster"
}

# Create task-definition
resource "aws_ecs_task_definition" "app" {
  family                   = "${local.common_tags.service_initial_name}-ecs-task-definition-family"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_task_definition_cpu
  memory                   = var.ecs_task_definition_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  container_definitions = jsonencode([{
    name        = "${local.common_tags.service_initial_name}-ecs-task-definition-container"
    image       = local.ecr_base_url
    essential   = true
    environment = []
    portMappings = [{
      protocol      = "tcp"
      containerPort = 80
      hostPort      = 80
    }]
    }
  ])
}

# Create ECS service with association of prev created LoadBalancer 
resource "aws_ecs_service" "new_service" {
    name            = "${local.common_tags.service_initial_name}-ecs-service"
    cluster         = aws_ecs_cluster.main.id
    task_definition = aws_ecs_task_definition.app.arn
    desired_count   = 1

    network_configuration {
        security_groups  = [aws_security_group.security_group.id]
        subnets = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
        assign_public_ip = true
    }

     load_balancer {
        target_group_arn = aws_alb_target_group.app.id
        container_name   = "${local.common_tags.service_initial_name}-ecs-task-definition-container"
        container_port   = 80
        }

    health_check_grace_period_seconds = 2
    capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
   }
    depends_on = [aws_alb_listener.http_listener]
}

# Create auto-scaling for the ECS service
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 3
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.new_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_as_policy" {
  name               = "ecs_auto_scaling_policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = 65
    scale_in_cooldown = 300
    scale_out_cooldown = 300

  }
}
