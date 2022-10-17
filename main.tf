##Module for Creating VPC
module "vpc_module" {
  source = "./modules/VPC"

  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  ## Tags
  vpc_name        = "${var.application_name_prefix}-vpc"
  vpc_environment = var.environment
}

##Module for creating IGW
module "igw_module" {
  source = "./modules/IGW"

  vpc_id         = module.vpc_module.vpc_id
  route_table_id = module.vpc_module.route_table_id

  ## Tags
  igw_name        = "${var.application_name_prefix}-internet-gateway"
  igw_environment = var.environment
}

##Module for creating Public Subnet
module "public_subnet01" {
  source = "./modules/Subnet"

  vpc_id            = module.vpc_module.vpc_id
  cidr_block        = "10.0.1.0/24"
  make_public       = true
  availability_zone = "us-east-2a"

  ## Tags
  subnet_name        = "${var.application_name_prefix}-pub-subnet01"
  subnet_environment = var.environment
}

##Module for creating Public Subnet2
module "public_subnet02" {
  source = "./modules/Subnet"

  vpc_id            = module.vpc_module.vpc_id
  cidr_block        = "10.0.2.0/24"
  make_public       = true
  availability_zone = "us-east-2b"

  ## Tags
  subnet_name        = "${var.application_name_prefix}-pub-subnet02"
  subnet_environment = var.environment
}

##Module for Creating Auto Scaling Group
module "web_auto_scalling" {
  source = "./modules/autoscalling_group"

  application_name_prefix = var.application_name_prefix
  image_id                = "ami-0f924dc71d44d23e2"
  instance_type           = "t2.micro"
  vpc_id                  = module.vpc_module.vpc_id
  instance_key            = "asus_key"
  desired_capacity        = 2
  max_size                = 2
  min_size                = 2
  vpc_zone_identifier     = [module.public_subnet01.subnet_id, module.public_subnet02.subnet_id]
  lb_security_group_id    = module.web_app_load_balancer.security_group_id
}

##Module for creating Load Balancer
module "web_app_load_balancer" {
  source = "./modules/load_balancer"

  target_subnets           = [module.public_subnet01.subnet_id, module.public_subnet02.subnet_id]
  loadbalancer_environment = var.environment
  vpc_id                   = module.vpc_module.vpc_id
  autoscaling_group_id     = module.web_auto_scalling.autoscaling_group_id
  application_name_prefix  = var.application_name_prefix
}

output "load_balancer_endpoint" {
  description = "Paste the URL on Browser to view welcome page for Apache"
  value       = module.web_app_load_balancer.load_balancer_arn
}