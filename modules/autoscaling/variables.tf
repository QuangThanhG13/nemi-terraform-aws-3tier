variable "project" {
    description = "Project name"
    type        = string
}

variable "environment" {
    description = "Environment name"
    type        = string
    default     = "dev"
}

variable "vpc" {
    description = "VPC configuration"
    type        = any
}

variable "sg" {
    description = "Security group configuration"
    type        = any
}

variable "db_config" {
    description = "Database configuration"
    type = object({
        endpoint     = string
        db_name     = string
        db_username = string
    })
}

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

variable "health_check_type" {
    description = "Health check type (EC2 or ELB)"
    type        = string
    default     = "ELB"
}

variable "health_check_grace_period" {
    description = "Health check grace period in seconds"
    type        = number
    default     = 300
}

variable "target_cpu_utilization" {
    description = "Target CPU utilization percentage"
    type        = number
    default     = 70
}

variable "health_check_interval" {
    description = "Health check interval in seconds"
    type        = number
    default     = 30
}

variable "health_check_path" {
    description = "Health check path"
    type        = string
    default     = "/"
}

variable "healthy_threshold" {
    description = "Number of consecutive health check successes required"
    type        = number
    default     = 2
}

variable "unhealthy_threshold" {
    description = "Number of consecutive health check failures required"
    type        = number
    default     = 2
}

variable "health_check_timeout" {
    description = "Health check timeout in seconds"
    type        = number
    default     = 5
}

variable "target_group_arns" {
    description = "List of target group ARNs"
    type        = list(string)
    default     = []
}