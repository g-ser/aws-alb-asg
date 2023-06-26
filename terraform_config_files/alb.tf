resource "aws_lb" "application_lb" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  # This application load balancer is an Internet facing load balancer 
  # which means that it has to be attached to the public subnets
  subnets            = module.vpc.public_subnets
  ip_address_type    = "ipv4"

  tags = {
    Terraform = "true"
  }
}

# create target group for alb
# the target group arn is passed as argument when creting the 
# Application Load Balancer

resource "aws_lb_target_group" "web_servers_tg" {
  name        = "web-servers-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "instance"
  health_check {
    path     = "/"
    protocol = "HTTP"
  }
  tags = {
    Terraform = "true"
  }
}

# The listener below binds the application load balancer and the 
# target group together

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.application_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_servers_tg.arn
  }
  tags = {
    Terraform = "true"
  }
}