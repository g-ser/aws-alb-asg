module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "alb-asg-vpc"

  azs = var.azs

  cidr = var.vpc_cidr

  private_subnets = var.private_subnets

  public_subnets = var.public_subnets

  // create an Internet gateway 
  create_igw = "true"

  // single NAT gateway
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false


  tags = {
    Terraform = "true"
  }

}

# Security group for the EC2 web instances
# which will be part of the Autoscaling Group  

resource "aws_security_group" "ec2_instances_sg" {
  name        = "allow_http_from_ALB_sg"
  description = "Allow http from the sg where ALB is part of"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "HTTP from the Security Group where ALB resides"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name      = "allow_http_from_ALB_sg"
    Terraform = "true"
  }
}

# Security group for the ALBs  

resource "aws_security_group" "alb_sg" {
  name        = "allow_http_from_Internet"
  description = "Allow http from Internet"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTP from the Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name      = "allow_http_from_Internet"
    Terraform = "true"
  }
}


