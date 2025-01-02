output "ip_node" {
  description = "control node public ip"
  value = aws_instance.control_node.public_ip
}