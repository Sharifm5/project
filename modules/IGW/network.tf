##Create Internet Gateway
resource "aws_internet_gateway" "network_igw" {
  vpc_id = var.vpc_id

  tags = {
    Name        = var.igw_name
    Environment = var.igw_environment
  }
}

##Create Routing Table for IGW
resource "aws_route" "attach-igw" {
  route_table_id         = var.route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.network_igw.id
}
