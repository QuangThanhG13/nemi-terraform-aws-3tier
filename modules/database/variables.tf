variable "project" {
    description = "Project name"
    type        = string
}

variable "vpc" {
    description = "VPC configuration"
    type        = any
}

variable "sg" {
    description = "Security group configuration"
    type        = any
}

variable "db_name" {
    description = "Database name"
    type        = string
}

variable "db_username" {
    description = "Database username"
    type        = string
}

variable "db_password" {
    description = "Database password"
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
    description = "PostgreSQL engine version"
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