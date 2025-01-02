resource "aws_db_subnet_group" "db_subnet_group" {
  subnet_ids  = var.vpc_private_subnets

  tags = {
    environment = var.environment
  }
}

resource "aws_security_group" "sg_rds" {
  description = "security group for the mysql rds"
  vpc_id  = var.vpc_id

  tags = {
    environment = var.environment
    terraform = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "rds_ingress_tcp_ipv4-us-east-1a" {
  security_group_id = aws_security_group.sg_rds.id
  cidr_ipv4         = var.private_subnets[0]
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "rds_ingress_tcp_ipv4-us-east-1b" {
  security_group_id = aws_security_group.sg_rds.id
  cidr_ipv4         = var.private_subnets[1]
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "rds_egress_traffic_ipv4" {
  security_group_id = aws_security_group.sg_rds.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_db_instance" "mysql_db" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = var.mysql_username
  password             = var.mysql_password
  parameter_group_name = "default.mysql8.0"

  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  multi_az = false
  publicly_accessible = false
  vpc_security_group_ids = [aws_security_group.sg_rds.id]
  skip_final_snapshot = true

  tags = {
    environment = var.environment
    terraform = true
  }
}

# --- nlb security_groups ---
resource "aws_security_group" "sg_nlb" {
  description = "security group for the application load balancer"
  vpc_id  = var.vpc_id

  tags = {
    environment = var.environment
    terraform = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "ingress_tcp_ipv4-us-east-1a" {
  security_group_id = aws_security_group.sg_nlb.id
  cidr_ipv4         = var.public_subnets[0]
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "ingress_tcp_ipv4-us-east-1b" {
  security_group_id = aws_security_group.sg_nlb.id
  cidr_ipv4         = var.public_subnets[1]
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "egress_traffic_ipv4-us-east-1a" {
  security_group_id = aws_security_group.sg_nlb.id
  cidr_ipv4         = var.private_subnets[0]
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "egress_traffic_ipv4-us-east-1b" {
  security_group_id = aws_security_group.sg_nlb.id
  cidr_ipv4         = var.private_subnets[1]
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_lb" "nlb" {
  internal           = false
  load_balancer_type = "network"
  security_groups    = [aws_security_group.sg_nlb.id]
  subnets            = var.vpc_private_subnets

  tags = {
    environment = var.environment
    terraform = true
  }
}

# Crear Target Group
resource "aws_lb_target_group" "target" {
  port        = 80
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Listener para el ALB
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target.arn
  }
}

# --- ec2 security_groups ---
resource "aws_security_group" "sg_ec2" {
  description = "security group for the ec2 template"
  vpc_id  = var.vpc_id

  tags = {
    environment = var.environment
    terraform = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.sg_ec2.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.sg_ec2.id
  cidr_ipv4         = var.public_subnets[1]
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.sg_ec2.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# --- ec2 template ---
resource "aws_launch_template" "ec2_template" {
  image_id = var.backend_ami
  instance_type = var.backend_instance_type

  key_name = var.key_pair_name

  network_interfaces {
    security_groups = [aws_security_group.sg_ec2.id]
  }
}

# --- autoscaling group ---
resource "aws_autoscaling_group" "autoscaling" {
  max_size                  = var.backend_autoscaling_max_size
  min_size                  = var.backend_autoscaling_min_size
  desired_capacity          = var.backend_autoscaling_desired_capacity

  vpc_zone_identifier = var.vpc_private_subnets

  health_check_grace_period = 300
  health_check_type         = "ELB"

  launch_template {
    id = aws_launch_template.ec2_template.id
  }

  target_group_arns = [aws_lb_target_group.target.arn]

  tag {
    key                 = "environment"
    value               = var.environment
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "cpu_policy_up" {
  name                   = "cpu-policy-up"
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.autoscaling.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 80.0
  }
}

resource "aws_autoscaling_policy" "cpu_policy_down" {
  name                   = "cpu-policy-up"
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.autoscaling.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 30.0
  }
}