# This terraform configuration creates a set of EC2 VMs which 
# serve as a basis for creating a k8s cluster consisting of
# a master node and two worker nodes
# All the nodes of the k8s cluster are placed in a custom VPC and more specifically 
# in the private subnet of the custom VPC (10.0.1.0/24)

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.4.0"
    }
  }
}

provider "aws" {
  region                   = var.region
  shared_credentials_files = [var.credentials_location]
}

# Create autoscaling group and attach it to the Application Load Balancer

resource "aws_autoscaling_group" "web_servers_asg" {  
  desired_capacity          = 2
  max_size                  = 2
  min_size                  = 1
  health_check_grace_period = 300
  vpc_zone_identifier = [for subnet_id in module.vpc.private_subnets : subnet_id]
  # if the ELB indicates that an instance is unhealthy, then the ASG will
  # terminate the unhealthy instance
  health_check_type = "ELB"
  # the target group below, is the one associated to the Application Load Balancer
  # and that's how the ASG is linked to the ALB
  target_group_arns = [aws_lb_target_group.web_servers_tg.arn]
  
  # Do not create the ASG if the Nat Gateway is not ready
  # This is because, the instances in the ASG need to access the Internet 
  # through the NAT gateway in order to install http web server and ssm agent
  depends_on = [module.vpc.aws_nat_gateway]

  launch_template {
    id = aws_launch_template.asg_template.id
  }

}




