variable "project" { 
    type = string
}

variable "vpc" { 
    type = any
}

variable "sg" {
    type = any
}

variable "db_name" { 
    type = string
}

variable "db_username" {
    type = string
    default = "admin"
}

variable "db_password" {
    type = string
    sensitive = true
}