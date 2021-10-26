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

resource "aws_security_group" "app_firewall" {
  name        = "app-firewall"
  description = "Rules for amongustodo app"
  vpc_id      = data.aws_vpc.default_vpc.id
}

resource "aws_security_group_rule" "allow_app_servers" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["58.182.65.238/32"]
  security_group_id = aws_security_group.app_firewall.id
}

resource "aws_instance" "app_server" {
  ami = data.aws_ami.docker_ami.id
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.app_firewall.id]
  tags = {
      Name = "amongustodo-api"
  }
}

output "instance_ips" {
  value = [aws_instance.app_server.public_ip]
}

output "instace_ids" {
  value = [aws_instance.app_server.id]
}