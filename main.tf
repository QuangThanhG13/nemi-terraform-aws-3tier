terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
    required_version = ">= 1.2.0"
}

provider "aws" { 
    region = var.aws_region
    
    default_tags {
        tags = var.tags
    }
}

module "networking" { 
    source = "./modules/networking" 

    project          = var.project
    vpc_cidr         = var.vpc_cidr
    private_subnets  = var.private_subnets
    public_subnets   = var.public_subnets
    database_subnets = var.database_subnets
}

module "database" { 
    source = "./modules/database" 

    project                 = var.project
    vpc                     = module.networking.vpc
    sg                      = module.networking.sg
    db_name                 = var.db_name
    db_username             = var.db_username
    db_password             = var.db_password
    instance_class          = var.instance_class
    allocated_storage       = var.allocated_storage
    engine_version          = var.engine_version
    backup_retention_period = var.backup_retention_period
    multi_az               = var.multi_az

    depends_on = [module.networking]
}

module "autoscaling" { 
    source = "./modules/autoscaling" 

    project                    = var.project
    vpc                        = module.networking.vpc
    sg                        = module.networking.sg
    db_config                 = {
        endpoint     = module.database.db_endpoint
        db_name     = module.database.db_name
        db_username = module.database.db_username
    }
    instance_type             = var.instance_type
    min_size                 = var.min_size
    max_size                 = var.max_size
    desired_capacity         = var.desired_capacity
    health_check_grace_period = var.health_check_grace_period
    health_check_type        = var.health_check_type

    depends_on = [module.database]
}

