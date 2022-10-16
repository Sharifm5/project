output "vpc_id" {
  value = aws_vpc.app_vpc.id
}

output "route_table_id" {
  value = aws_vpc.app_vpc.main_route_table_id
}