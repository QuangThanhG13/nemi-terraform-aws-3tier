output "db_instance" {
    description = "The database instance"
    value = aws_db_instance.database
    sensitive = true
}

output "db_endpoint" {
    description = "The database endpoint"
    value = aws_db_instance.database.endpoint
}

output "db_name" {
    description = "The database name"
    value = aws_db_instance.database.db_name
}

output "db_username" {
    description = "The database username"
    value = aws_db_instance.database.username
    sensitive = true
}
