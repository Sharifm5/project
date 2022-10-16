##Creating Public and Private subnets
resource "aws_subnet" "app_subnet" {
  vpc_id            = var.vpc_id
  cidr_block        = var.cidr_block
  availability_zone = var.availability_zone

  map_public_ip_on_launch = var.make_public

  tags = {
    Name        = var.subnet_name
    Environment = var.subnet_environment
  }
}