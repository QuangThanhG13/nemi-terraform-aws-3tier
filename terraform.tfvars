project     = "my-project"
environment = "dev"
aws_region  = "ap-southeast-1"

# VPC Configuration
vpc_cidr         = "10.0.0.0/16"
private_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
public_subnets   = ["10.0.101.0/24", "10.0.102.0/24"]
database_subnets = ["10.0.201.0/24", "10.0.202.0/24"]

# Database Configuration
db_name           = "myappdb"
db_username       = "admin"
db_password       = "your-secure-password"  # Consider using AWS Secrets Manager
instance_class    = "db.t4g.micro"
allocated_storage = 20
engine_version    = "14"

# Auto Scaling Configuration
instance_type       = "t3.micro"
min_size           = 1
max_size           = 3
desired_capacity   = 2

# Tags
tags = {
    Environment = "dev"
    Terraform   = "true"
    Project     = "my-project"
    Owner       = "devops-team"
} 