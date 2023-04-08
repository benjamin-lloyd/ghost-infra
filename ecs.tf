resource "aws_ecr_repository" "ghost_app" {
  name                 = "ghost-app-${var.environment}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
  }
}

resource "aws_ecs_task_definition" "ghost_task_def" {
  family                = "service"
  container_definitions = jsonencode([
    {
      "cpu": var.desired_cpu,
      "environment": [
          {"name": "NODE_ENV", "value": "development"}
      ],
      "essential": true,
      requires_compatibilities = ["FARGATE"]
      "image": "${aws_ecr_repository.ghost_app.repository_url}",
      "memory": var.desired_memory,
      "name": "ghost-app",
      "portMappings": [
        {
          "containerPort": 2368,
          "hostPort": var.host_port
        }
      ],
      "mountPoints": [
        {
          "sourceVolume": "ghost-efs-${var.environment}",
          "containerPath": "/var/lib/ghost"
        }
      ]
    }
   ]
  )
  
  volume {
    name = "ghost-efs-${var.environment}"
    efs_volume_configuration {
      file_system_id          = aws_efs_file_system.ghost_efs.id
      root_directory          = "/"
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2999
    }
  }
}

resource "aws_ecs_cluster" "ghost_cluster" {
  name = "ghost-app-ecs-cluster-${var.environment}"
}

resource "aws_ecs_service" "service" {
  name            = "ghost-app-ecs-service-${var.environment}"
  cluster         = aws_ecs_cluster.ghost_cluster.id
  task_definition = aws_ecs_task_definition.ghost_task_def.arn
  desired_count   = 1
}

