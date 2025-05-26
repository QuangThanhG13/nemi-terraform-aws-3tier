output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = module.autoscaling.alb_dns_name
} 

output "db_password" { 
    value = module.database.config.password
    sensitive = true  
}

output "lb_dns_name" { 
    value = module.autoscaling.lb_dns
}