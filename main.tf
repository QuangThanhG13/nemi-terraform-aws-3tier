locals {
 project = "terraform-nemi"
}

provider "aws" { 
    region = "ap-southeast-2" 
}

module "networking" { 
    source = "./modules/networking" 

    project = local.project 
    vpc_cidr = "10.0.0.0/16" 
    private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
    public_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
    database_subnets = ["10.0.5.0/24", "10.0.6.0/24"]
}

module "database" { 
    source = "./modules/database" 

    project = local.project 
    vpc = module.networking.vpc 
    sg = module.networking.sg 
    db_name = "myapp"
    db_username = "dbadmin"
    db_password = "MySecurePassword123!"
}

module "autoscaling" { 
    source = "./modules/autoscaling" 

    project = local.project 
    vpc = module.networking.vpc 
    sg = module.networking.sg 
    db_config = module.database.config 
}

