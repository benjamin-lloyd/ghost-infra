
resource "aws_security_group" "ghost_alb_sg" {
  name = "ghost-app-sg-alb-${var.environment}"
  description = "Security Group for ALB access"
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 2368
    to_port = 2368
    protocol = "tcp"
    security_groups = [aws_security_group.ghost_ecs_sg.id]
  }
}


resource "aws_lb" "ghost_alb" {
  name               = "ghost-app-alb-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ghost_alb_sg.id]
  subnets            = module.vpc.public_subnets
 
  enable_deletion_protection = false
}
 
resource "aws_lb_target_group" "ghost_tg" {
  name        = "ghost-app-tg-${var.environment}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"
 
  health_check {
   healthy_threshold   = "3"
   interval            = "30"
   protocol            = "HTTP"
   matcher             = "200"
   timeout             = "3"
   path                = "/"
   unhealthy_threshold = "2"
  }
}

resource "aws_alb_listener" "ghost_http" {
  load_balancer_arn = aws_lb.ghost_alb.arn
  port              = 80
  protocol          = "HTTP"
 
  default_action {
   type = "forward"
   target_group_arn = aws_lb_target_group.ghost_tg.arn 
   }
}
 
#resource "aws_alb_listener" "https" {
#  load_balancer_arn = aws_lb.main.id
#  port              = 443
#  protocol          = "HTTPS"
 
#  ssl_policy        = "ELBSecurityPolicy-2016-08"
#  certificate_arn   = var.alb_tls_cert_arn
 
#  default_action {
#    target_group_arn = aws_alb_target_group.main.id
#    type             = "forward"
#  }
#}
