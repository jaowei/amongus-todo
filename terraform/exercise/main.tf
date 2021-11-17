data "aws_vpc" "default_vpc" {
  default = true
}

data "aws_ami" "docker_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["*amazon-ecs-optimized*"]
  }
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
}

resource "local_file" "private_key" {
	content = tls_private_key.this.private_key_pem
	filename = "server.pem"
}

resource "aws_key_pair" "homework_ec2_key" {
  key_name   = "homework_ec2_key"       
  public_key = tls_private_key.this.public_key_openssh
}

resource "aws_security_group" "app_firewall" {
  name        = "app-firewall"
  description = "Rules for homework app"
  vpc_id      = data.aws_vpc.default_vpc.id
}

resource "aws_security_group_rule" "ssh_rules" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["58.182.16.240/32"]
  security_group_id = aws_security_group.app_firewall.id
}

resource "aws_security_group_rule" "egress_rule" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.app_firewall.id
}

resource "aws_instance" "app_server" {
  ami = data.aws_ami.docker_ami.id
  instance_type = "t2.micro"
  key_name = "homework_ec2_key"
  vpc_security_group_ids = [aws_security_group.app_firewall.id]
  tags = {
      Name = "terraform-homework"
  }
}