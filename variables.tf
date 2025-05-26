variable "project" {
    description = "Project name"
    type        = string
    default     = "terraform-project"
}

variable "environment" {
    description = "Environment (dev/staging/prod)"
    type        = string
    default     = "dev"
}

variable "aws_region" {
    description = "AWS Region"
    type        = string
    default     = "ap-southeast-1"
}

# VPC Variables
variable "vpc_cidr" {
    description = "CIDR block for VPC"
    type        = string
    default     = "10.0.0.0/16"
}

variable "private_subnets" {
    description = "List of private subnet CIDR blocks"
    type        = list(string)
    default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnets" {
    description = "List of public subnet CIDR blocks"
    type        = list(string)
    default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "database_subnets" {
    description = "List of database subnet CIDR blocks"
    type        = list(string)
    default     = ["10.0.201.0/24", "10.0.202.0/24"]
}

# Database Variables
variable "db_name" {
    description = "Name of the database"
    type        = string
    default     = "myappdb"
}

variable "db_username" {
    description = "Database administrator username"
    type        = string
    default     = "admin"
}

variable "db_password" {
    description = "Database administrator password"
    type        = string
    sensitive   = true
}

variable "instance_class" {
    description = "RDS instance class"
    type        = string
    default     = "db.t4g.micro"
}

variable "allocated_storage" {
    description = "Allocated storage in GB"
    type        = number
    default     = 20
}

variable "engine_version" {
    description = "Database engine version"
    type        = string
    default     = "14"
}

variable "backup_retention_period" {
    description = "Backup retention period in days"
    type        = number
    default     = 7
}

variable "multi_az" {
    description = "Enable Multi-AZ deployment"
    type        = bool
    default     = false
}

# Auto Scaling Variables
variable "instance_type" {
    description = "EC2 instance type"
    type        = string
    default     = "t3.micro"
}

variable "min_size" {
    description = "Minimum size of the Auto Scaling Group"
    type        = number
    default     = 1
}

variable "max_size" {
    description = "Maximum size of the Auto Scaling Group"
    type        = number
    default     = 3
}

variable "desired_capacity" {
    description = "Desired capacity of the Auto Scaling Group"
    type        = number
    default     = 2
}

variable "health_check_grace_period" {
    description = "Health check grace period in seconds"
    type        = number
    default     = 300
}

variable "health_check_type" {
    description = "Health check type (EC2 or ELB)"
    type        = string
    default     = "ELB"
}

# Tags
variable "tags" {
    description = "Default tags for all resources"
    type        = map(string)
    default     = {
        Environment = "dev"
        Terraform   = "true"
        Project     = "terraform-project"
    }
} 