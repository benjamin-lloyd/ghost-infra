resource "aws_security_group" "efs_sg" {
  name = "ghost-app-sg-efs-${var.environment}"
  description = "Security Group for ECS to EFS access"
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port = 2049
    to_port = 2049
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

resource "aws_efs_file_system" "ghost_efs" {
  creation_token = "ghost-app-${var.environment}"
  tags = "${
             merge(local.account_tags, 
             {
               Name    =  "ghost-efs-mount-${var.environment}"
             }
            )
 }"

 # tags = {
 #   Name = "ghost-efs-mount-${var.environment}"
 # }
}

resource "aws_efs_mount_target" "private_subnet_1a" {
  file_system_id = aws_efs_file_system.ghost_efs.id
  subnet_id      = module.vpc.private_subnets[0]
  security_groups = ["${aws_security_group.efs_sg.id}"]
}
resource "aws_efs_mount_target" "private_subnet_1b" {
  file_system_id = aws_efs_file_system.ghost_efs.id
  subnet_id      = module.vpc.private_subnets[1]
  security_groups = ["${aws_security_group.efs_sg.id}"]
}
resource "aws_efs_mount_target" "private_subnet_1c" {
  file_system_id = aws_efs_file_system.ghost_efs.id
  subnet_id      = module.vpc.private_subnets[2]
  security_groups = ["${aws_security_group.efs_sg.id}"]
}
