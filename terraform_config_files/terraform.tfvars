# credentials for connecting to AWS
credentials_location = "~/.aws/credentials"

ec2_instance_type = "t3.micro"
ec2_ami_id        = "ami-04e4606740c9c9381"

# key for connecting to EC2 instances for managing them
key_name = "gs_key_pair"

# VPC

region = "eu-north-1"

azs = ["eu-north-1a", "eu-north-1b"]

vpc_cidr = "10.0.0.0/16"

private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]

public_subnets = ["10.0.101.0/24", "10.0.102.0/24"]