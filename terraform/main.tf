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

variable "ec2_key_public" {
  type = string
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
}

resource "aws_key_pair" "ec2_key" {
  key_name   = "ec2_key"       
  public_key = "${var.ec2_key_public}"
}

resource "aws_security_group" "app_firewall" {
  name        = "app-firewall"
  description = "Rules for amongustodo app"
  vpc_id      = data.aws_vpc.default_vpc.id
}

resource "aws_security_group_rule" "ssh_rules" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.app_firewall.id
}

resource "aws_security_group_rule" "http_rule" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.app_firewall.id
}

resource "aws_security_group_rule" "https_rule" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
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
  key_name = "ec2_key"
  vpc_security_group_ids = [aws_security_group.app_firewall.id]
  tags = {
      Name = "amongustodo-api"
  }
}