##Creating VPC on AWS
resource "aws_vpc" "app_vpc" {
  cidr_block       = var.cidr_block
  instance_tenancy = var.instance_tenancy

  tags = {
    Name        = var.vpc_name
    Environment = var.vpc_environment
  }
}