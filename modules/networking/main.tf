data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" { 
    source = "terraform-aws-modules/vpc/aws" 
    version = "5.1.1" 

    name = "${var.project}-vpc" 
    cidr = var.vpc_cidr
    azs = data.aws_availability_zones.available.names

    private_subnets = var.private_subnets
    public_subnets = var.public_subnets
    database_subnets = var.database_subnets

    create_database_subnet_group = true
    
    enable_nat_gateway = true 
    single_nat_gateway = true
    one_nat_gateway_per_az = false
    
    enable_dns_hostnames = true
    enable_dns_support = true

    tags = {
        Environment = "production"
        CostCenter = "networking"
    }
}

data "aws_region" "current" {}

locals {
    interface_endpoints = {
        ssm = "com.amazonaws.${data.aws_region.current.name}.ssm"
        ssmmessages = "com.amazonaws.${data.aws_region.current.name}.ssmmessages"
        ec2messages = "com.amazonaws.${data.aws_region.current.name}.ec2messages"
    }
}

resource "aws_vpc_endpoint" "interface_endpoints" {
    for_each = local.interface_endpoints

    vpc_id = module.vpc.vpc_id
    service_name = each.value
    vpc_endpoint_type = "Interface"
    subnet_ids = module.vpc.private_subnets
    private_dns_enabled = true
    security_group_ids = [aws_security_group.vpc_endpoints.id]

    tags = {
        Name = "${var.project}-${each.key}-endpoint"
        Environment = "production"
    }
}

resource "aws_security_group" "vpc_endpoints" {
    name_prefix = "${var.project}-vpc-endpoints-"
    description = "Security group for VPC endpoints"
    vpc_id = module.vpc.vpc_id

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = [var.vpc_cidr]
    }

    tags = {
        Name = "${var.project}-vpc-endpoints"
        Environment = "production"
    }
}

module "lb_sg" { 
    source = "terraform-in-action/sg/aws" 
    vpc_id = module.vpc.vpc_id
    ingress_rules = [ 
        { 
            port = 80 
            cidr_blocks = ["0.0.0.0/0"]
        }
    ]
    egress_rules = [
        {
            port = 0
            protocol = "-1"
            cidr_blocks = ["0.0.0.0/0"]
        }
    ]
}

module "web_sg" { 
    source = "terraform-in-action/sg/aws" 
    vpc_id = module.vpc.vpc_id
    ingress_rules = [ 
        { 
            port = 80
            cidr_blocks = ["0.0.0.0/0"]
        }
    ]
    egress_rules = [
        {
            port = 0
            protocol = "-1"
            cidr_blocks = ["0.0.0.0/0"]
        }
    ]
}

module "db_sg" { 
    source = "terraform-in-action/sg/aws" 
    vpc_id = module.vpc.vpc_id
    ingress_rules = [ 
        { 
            port = 5432
            security_groups = [module.web_sg.security_group.id]
        }
    ]
    egress_rules = [
        {
            port = 0
            protocol = "-1"
            cidr_blocks = ["0.0.0.0/0"]
        }
    ]
}