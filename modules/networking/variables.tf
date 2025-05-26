variable "project" {
    description = "Project name"
    type        = string
}

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

variable "enable_nat_gateway" {
    description = "Enable NAT Gateway"
    type        = bool
    default     = true
}

variable "single_nat_gateway" {
    description = "Use single NAT Gateway"
    type        = bool
    default     = true
}
