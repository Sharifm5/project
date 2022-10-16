output "security_group_id" {
  value = aws_security_group.allow_http.id
}

output "load_balancer_arn" {
  value = aws_lb.webload_balancer.dns_name
}