variable "project" {
    type = string
    description = "Project name"
}

variable "vpc" {
    type = any
    description = "VPC configuration from networking module"
}

variable "sg" {
    type = any
    description = "Security groups from networking module"
}

variable "db_config" {
    type = any
    description = "Database configuration from database module"
}