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

resource "aws_iam_role" "ghost_ecs_execution_role" {
  name = "GhostECSExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
  })
}

resource "aws_iam_role_policy_attachment" "ghost_ecs_role_policy_attach" {
  role       = aws_iam_role.ghost_ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_security_group" "ghost_ecs_sg" {
  name = "ghost-app-sg-ecs-${var.environment}"
  description = "Security Group for ECS access from LB and to EFS"
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port = 2368
    to_port = 2368
    protocol = "tcp"
    #security_groups = ["${aws_security_group.ghost_ecs_sg.id}"]
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_task_definition" "ghost_task_def" {
  family                   = "ghost_task_definition-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.desired_cpu
  memory                   = var.desired_memory
  task_role_arn            = aws_iam_role.ghost_ecs_execution_role.arn
  execution_role_arn       = aws_iam_role.ghost_ecs_execution_role.arn
  container_definitions    = jsonencode([
    {
      environment: [
          {name: "NODE_ENV", value: "development"}
      ],
      essential: true,
      image: "${aws_ecr_repository.ghost_app.repository_url}",
      name: "ghost-app-${var.environment}",
      portMappings: [
        {
          "containerPort": 2368,
          "hostPort": var.host_port
        }
      ],
      mountPoints: [
        {
          "sourceVolume": "ghost-efs-${var.environment}",
          "containerPath": "/var/lib/ghost"
        }
      ],
      "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-create-group": "true",
                    "awslogs-group": "/ecs/ghost-app-${var.environment}",
                    "awslogs-region": var.region,
                    "awslogs-stream-prefix": "ecs"
                }
     }
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

resource "aws_ecs_service" "ghost_service" {
  name            = "ghost-app-ecs-service-${var.environment}"
  cluster         = aws_ecs_cluster.ghost_cluster.id
  task_definition = aws_ecs_task_definition.ghost_task_def.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets         = module.vpc.private_subnets
    security_groups = [aws_security_group.ghost_ecs_sg.id]
  }

   load_balancer {
   target_group_arn = aws_lb_target_group.ghost_tg.arn
   container_name   = "ghost-app-${var.environment}"
   container_port   = 2368
 }
}

