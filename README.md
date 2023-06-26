# What's inside this repo<a name="repo_content"></a>

The goal of the terraform configuration scripts included in this folder, is to create an Application Load Balancer (ALB) on AWS, as well as an Autoscaling Group (ASG). The ASG integrates with the ALB in the sense that the EC2 instances launched by the ASG are created within the target group of the ALB. The load balancer listener binds the target group and the ALB together. The relations of the entities described above, can be perceived as follows: ALB <--> Listener <--> Target Group <--> ASG

# Architecture<a name="architecture"></a> 

A high level view of the virtual infrastructure which will be created by the terraform configuration files included in this repo can be seen in the picture below: 

 ![High Level Setup](/assets/images/ALB-ASG-AWS.png)

 #### Notes
 * The Application Load Balancer is associated with two public subnets
 * The ASG creates EC2 instances in two Availability Zones (in the corresponding private subnets)
 * The security group where the ALB resides allows ingress HTTP traffic from any source
 * The security group where the ASG provisions the EC2 instances allows ingress HTTP traffic only from the security group of the ALB
 * The EC2 instances can access the Internet through the NAT gateway
 * All the network related resources (i.e. VPC, NAT Gateway, Internet Gateway, private subnets, public subnets etc.) were created using the following VPC module(version 5.0.0): [AWS VPC Module](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest)
 * Traffic from the internet flows in to the Elastic IP address, which is dynamically created when you deploy an internet-facing Application Load Balancer.
 * The ASG creates instances in the target group where ALB forwards HTTP traffic
 * The EC2 instances (which are provisioned by the ASG) run a web server which is configured by providing the script [web-server-install.sh](/terraform_config_files/scripts/web-server-install.sh) via the user_data attribute of the [launch template](/terraform_config_files/launch_template.tf)  


# Prerequisites for working with the repo<a name="prerequisites"></a>

* Your local machine, has to have terraform installed so you can run the terraform configuration files included in this repository. This repo has been tested with terraform 1.5.1
* You need to generate a pair of aws_access_key_id-aws_secret_access_key for your AWS user using the console of AWS and provide the path where the credentials are stored to the variable called ```credentials_location``` which is in ```/terraform_config_files/terraform.tfvars``` file. This is used by terraform to make programmatic calls to AWS.
* You need to use AWS console (prior to running the terraform configuration files) to generate a key-pair whose name you need to specify in the ``provision_infra/terraform.tfvars`` file (variable name is ```key_name```). The ```pem``` file (which has to be downloaded from AWS and stored on your local machine) of the key pair, is used in order for Ansible to authenticate when connecting to the EC2 instances with ssh.
* If you want to access the CLI of the Instances, go through the section [Accessing the EC2 instances](#access_instances) and make sure that you have [AWS CLI installed](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html), as well as [Session Manager plugin](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html) and the proper configuration in ```~/.ssh/config``` and ```~/.aws/config``` files. 


# Accessing the EC2 instances<a name="access_instances"></a>

Although the AWS security group where the instances are placed does **not** include any ingress rule to allow SSH traffic (port 22); using SSH to connect to them is still possible thanks to AWS Systems Manager. Terraform installs SSM Agent on the instances. 

In order for a client (e.g. you local machine) to ssh to the EC2 instances, it needs to fullfil the below:

* Have AWS CLI installed: [Installation of AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
* Have the Session Manager plugin for the AWS CLI installed: [Install the Session Manager plugin](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html)
* Have the configuration below into the SSH configuration file of your local machine (typically located at ```~/.ssh/config```)
<br/><br/>
```shell
# SSH over Session Manager
host i-* mi-*
    ProxyCommand sh -c "aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'"
```
<br/><br/>
* Specify in the ```~/.aws/config``` file the AWS region like below:
<br/><br/>
```shell
[default]
region=<AWS_REGION>
```
<br/><br/>
You can connect using the command: ```ssh -i <KEY_PEM_FILE> <USER_NAME>@<INSTANCE_ID>```
The ```USER_NAME``` of the EC2 instances is ```ec2-user```. The ```KEY_PEM_FILE``` is the path pointing to the pem file of the key-pair that you need to generate as discussed in the [Prerequisites for working with the repo](#prerequisites) section. You can retrieve the ```INSTANCE_ID``` from the AWS console. 

# Provision the infrastructure by running Terraform<a name="run_terraform"></a>

In the folder [terraform_config_files](/terraform_config_files/) run:
```terraform apply```