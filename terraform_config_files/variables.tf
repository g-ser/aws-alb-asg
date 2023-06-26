variable "ec2_instance_type" {
  description = "The instance type of EC2 instances part of the ASG"
  type        = string
}

variable "ec2_ami_id" {
  description = "The ami of EC2 instances"
  type        = string
}

variable "key_name" {
  description = "Key name of the key pair used to connect to EC2 instances"
  type        = string
}

variable "azs" {
  description = "The AZs where instances of ALB will be created"
  type        = list(any)
}

variable "private_subnets" {
  type        = list(any)
  description = "List of private subnets"
}

variable "public_subnets" {
  type        = list(any)
  description = "List of public subnets"
}

variable "vpc_cidr" {
  description = "The ami of EC2 instances"
  type        = string
}

variable "credentials_location" {
  description = "The location in your local machine of the aws_access_key_id and aws_secret_access_key"
  type        = string
}

variable "region" {
  description = "The AWS region where the infrastructure will be provisioned"
  type        = string
}
