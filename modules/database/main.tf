resource "aws_db_instance" "database" { 
    identifier = "${var.project}-db" 
    
    engine = "postgres"
    engine_version = "14"
    instance_class = "db.t4g.micro"

    allocated_storage = 20
    storage_type = "gp3"

    db_name = var.db_name
    username = var.db_username
    password = var.db_password

    db_subnet_group_name = var.vpc.database_subnet_group_name
    vpc_security_group_ids = [var.sg.db.id]

    backup_retention_period = 7
    backup_window = "03:00-04:00"
    maintenance_window = "Mon:04:00-Mon:05:00"

    storage_encrypted = true
    skip_final_snapshot = true
    deletion_protection = false
    publicly_accessible = false

    auto_minor_version_upgrade = true
    multi_az = false

    tags = {
        Name = "${var.project}-db"
    }
}

resource "aws_db_parameter_group" "main" {
    name_prefix = "${var.project}-pg-"
    family = "postgres14"

    parameter {
        name = "work_mem"
        value = "4096"
        apply_method = "pending-reboot"
    }

    parameter {
        name = "maintenance_work_mem"
        value = "65536"
        apply_method = "pending-reboot"
    }

    parameter {
        name = "autovacuum"
        value = "1"
        apply_method = "pending-reboot"
    }

    parameter {
        name = "autovacuum_vacuum_scale_factor"
        value = "0.1"
        apply_method = "pending-reboot"
    }
}