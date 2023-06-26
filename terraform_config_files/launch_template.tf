resource "aws_launch_template" "asg_template" {
  name = "asg_template"

  image_id = var.ec2_ami_id

  instance_type = var.ec2_instance_type

  key_name = var.key_name

  vpc_security_group_ids = [aws_security_group.ec2_instances_sg.id]

  user_data = data.cloudinit_config.web_server.rendered

  iam_instance_profile {
    name = aws_iam_instance_profile.ssm_iam_profile.name
  }


}

data "cloudinit_config" "web_server" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = data.local_file.ssm_agent.content
  }

  part {
    content_type = "text/x-shellscript"
    content      = data.local_file.web_server.content
  }

}

# script that installs ssm agent

data "local_file" "ssm_agent" {
  filename = "${path.module}/scripts/ssm-agent-install.sh"
}

data "local_file" "web_server" {
  filename = "${path.module}/scripts/web-server-install.sh"
}