# AWS Terraform module

Terraform module to provision base infrastructure on AWS for on-boarding new applications. Module automates the process of provisionig various network and governance modules including VPC, Subnets, Security Groups, Auto Scaling Groups and application load balancer on AWS.

### Provisioning VPC in the Cloud

Module vpc_module is used to provision Virtual Private Cloud in the AWS environment. In order to invoke this module we need to pass in few parameters including `cidr_block`, `instance_tenancy`, `application_name_prefix` and `environment` attributes. Please note since the application name and environment can be common across the deployment so we will keep them in the variable file.

```hcl
module "vpc_module" {
  source = "./modules/VPC"

  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  ## Tags
  vpc_name        = "${var.application_name_prefix}-vpc"
  vpc_environment = var.environment
}
```

### Provisioning IGW in the Cloud

Module igw_module is used to provision Internet Gateway to enable traffic to the internat. In order to invoke this module we need to pass in few parameters including `vpc_id`, `instance_tenancy`, `application_name_prefix` and `environment` attributes. Please note since the application name and environment can be common across the deployment so we will keep them in the variable file.

```hcl
module "igw_module" {
  source = "./modules/IGW"

  vpc_id         = module.vpc_module.vpc_id
  route_table_id = module.vpc_module.route_table_id

  ## Tags
  igw_name        = "${var.application_name_prefix}-internet-gateway"
  igw_environment = var.environment
}
```

### Provisioning Public/Private subnet in the Cloud

Module public_subnet01 and public_subnet02 is used to provision Public subnets in AWS. In order to invoke this module we need to pass in few parameters including `vpc_id`, `cidr_block`, `make_public`, `availability_zone`, `application_name_prefix` and `environment` attributes. Please note since the application name and environment can be common across the deployment so we will keep them in the variable file.

```hcl
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
```

### Provisioning AutoScaling Group in the Cloud

Module web_auto_scalling is used to provision Auto Scaling Group in AWS. In order to invoke this module we need to pass in few parameters including `image_id`, `instance_type`, `vpc_id`, `instance_key`, `application_name_prefix`, `desired_capacity`, `max_size`, `min_size`, `vpc_zone_identifier` and `lb_security_group_id` attributes. Please note since the application name and environment can be common across the deployment so we will keep them in the variable file.

```hcl
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
```

### Provisioning AutoScaling Group in the Cloud

Module web_app_load_balancer is used to provision Application Load Balancer in AWS. In order to invoke this module we need to pass in few parameters including `target_subnets`, `loadbalancer_environment`, `vpc_id`, `autoscaling_group_id` and `application_name_prefix` attributes. Please note since the application name and environment can be common across the deployment so we will keep them in the variable file.

```hcl
module "web_app_load_balancer" {
  source = "./modules/load_balancer"

  target_subnets           = [module.public_subnet01.subnet_id, module.public_subnet02.subnet_id]
  loadbalancer_environment = var.environment
  vpc_id                   = module.vpc_module.vpc_id
  autoscaling_group_id     = module.web_auto_scalling.autoscaling_group_id
  application_name_prefix  = var.application_name_prefix
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Steps to Trigger the Code

Trigger the following command to initialize the providers

```
terraform init
```

Trigger the following command to Plan the configuration

```
terraform plan
```

Trigger the following command to Apply the configuration

```
terraform apply --auto-approve
```

Trigger the following command to Cleanup the provisioned environment

```
terraform destroy
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.20.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.20.0 |

## Modules

No modules.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="environment"></a> [environment](#input\_environment) | Environment to provision the environment for | `string` | `""` | yes |
| <a name="region"></a> [region](#input\_region) | Region to Deploy the environment | `string` | `"us-east-2"` | yes |
| <a name="application_name_prefix"></a> [application_name_prefix](#input\_application_name_prefix) | Application Name | `string` | `"testapplication"` | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="load_balancer_endpoint"></a> [load_balancer_endpoint](#output\_load_balancer_endpoint) | URL for hosting application|
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module is maintained.