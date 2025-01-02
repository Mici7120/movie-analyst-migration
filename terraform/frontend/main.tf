# --- alb security_groups ---
resource "aws_security_group" "sg_alb" {
  description = "security group for the application load balancer"
  vpc_id  = var.vpc_id

  tags = {
    environment = var.environment
    terraform = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "ingress_http_ipv4" {
  security_group_id = aws_security_group.sg_alb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "egress_traffic_ipv4" {
  security_group_id = aws_security_group.sg_alb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_lb" "alb" {
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_alb.id]
  subnets            = var.vpc_public_subnets

  tags = {
    environment = var.environment
    terraform = true
  }
}

# Crear Target Group
resource "aws_lb_target_group" "target" {
  port        = 80
  protocol    = "HTTP"
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
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

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
  image_id = var.frontend_ami
  instance_type = var.frontend_instance_type

  key_name = var.key_pair_name

  network_interfaces {
    security_groups = [aws_security_group.sg_ec2.id]
  }
}

# --- autoscaling group ---
resource "aws_autoscaling_group" "autoscaling" {
  max_size                  = var.frontend_autoscaling_max_size
  min_size                  = var.frontend_autoscaling_min_size
  desired_capacity          = var.frontend_autoscaling_desired_capacity

  vpc_zone_identifier = var.vpc_public_subnets

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