resource "aws_security_group" "sg_control" {
  description = "security group for the control node instance"
  vpc_id  = var.vpc_id

  tags = {
    environment = var.environment
    terraform = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.sg_control.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.sg_control.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_instance" "control_node" {

  subnet_id     = var.private_subnet
  instance_type = var.instance_type
  ami = var.ami

  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.sg_control.id]

  tags = {
    terraform = "true"
    environment = var.environment
  }
}