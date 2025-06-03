data "aws_ami" "ami" { 
    most_recent = true 

    filter { 
        name = "name" 
        values = ["amzn2-ami-hvm-2.0.*-arm64-gp2"]
    }

    owners = ["amazon"]
}

resource "aws_iam_instance_profile" "web" {
    name_prefix = "${var.project}-web-"
    role = aws_iam_role.web.name
}

resource "aws_iam_role" "web" {
    name_prefix = "${var.project}-web-"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
            }
        ]
    })


    tags = {
        Name = "${var.project}-web-role"
    }
}

resource "aws_iam_role_policy_attachment" "ssm" {
    role = aws_iam_role.web.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "ec2_permissions" {
    name = "${var.project}-ec2-permissions"
    role = aws_iam_role.web.name

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "rds:DescribeDBInstances",
                    "ec2:DetachNetworkInterface",
                    "ec2:AttachNetworkInterface",
                    "ec2:DescribeNetworkInterfaces"
                ]
                Resource = "*"
            }
        ]
    })
}

resource "aws_key_pair" "web" {
    key_name_prefix = "${var.project}-web-"
    public_key = file("${path.module}/web.pub")
}

resource "aws_launch_template" "web" { 
    name_prefix = "${var.project}-web-"
    image_id = data.aws_ami.ami.id
    instance_type = var.instance_type

    iam_instance_profile {
        name = aws_iam_instance_profile.web.name
    }

    network_interfaces {
        associate_public_ip_address = false
        security_groups = [var.sg.web.id]
    }

    user_data = base64encode(templatefile("${path.module}/run.sh", {
        db_endpoint = var.db_config.endpoint
        db_name     = var.db_config.db_name
        db_username = var.db_config.db_username
    }))

    metadata_options {
        http_endpoint = "enabled"
        http_tokens = "required"
    }

    tags = {
        Name = "${var.project}-launch-template"
    }

    lifecycle {
        create_before_destroy = true
    }
}

data "aws_region" "current" {}

resource "aws_autoscaling_group" "web" { 
    name = "${var.project}-asg" 
    min_size = var.min_size
    max_size = var.max_size
    desired_capacity = var.desired_capacity
    vpc_zone_identifier = var.vpc.private_subnets
    target_group_arns = module.alb.target_group_arns
    health_check_type = var.health_check_type
    health_check_grace_period = var.health_check_grace_period

    launch_template {
        id = aws_launch_template.web.id
        version = aws_launch_template.web.latest_version
    }

    dynamic "tag" {
        for_each = {
            Name = "${var.project}-web"
            Environment = var.environment
            Project = var.project
        }
        content {
            key = tag.key
            value = tag.value
            propagate_at_launch = true
        }
    }

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_autoscaling_policy" "cpu_policy" {
    name = "${var.project}-cpu-policy"
    autoscaling_group_name = aws_autoscaling_group.web.name
    policy_type = "TargetTrackingScaling"

#target tracking policy is a policy that scales the ASG based on the CPU utilization -> increase or decrease the ec2 instances
    target_tracking_configuration {
        predefined_metric_specification {
            predefined_metric_type = "ASGAverageCPUUtilization"
        }
        target_value = var.target_cpu_utilization
    }
}

module "alb" {
    source = "terraform-aws-modules/alb/aws"
    version = "~> 8.0"

    name = "${var.project}-alb"

    vpc_id = var.vpc.vpc_id
    subnets = var.vpc.public_subnets
    security_groups = [var.sg.lb.id]

    target_groups = [
        {
            name_prefix = "web-"
            backend_protocol = "HTTP"
            backend_port = 80
            target_type = "instance"
            health_check = {
                enabled = true
                interval = var.health_check_interval
                path = var.health_check_path
                port = "traffic-port"
                healthy_threshold = var.healthy_threshold
                unhealthy_threshold = var.unhealthy_threshold
                timeout = var.health_check_timeout
                protocol = "HTTP"
                matcher = "200-399"
            }
        }
    ]

    http_tcp_listeners = [
        {
            port = 80
            protocol = "HTTP"
            target_group_index = 0
        }
    ]

    tags = {
        Name = "${var.project}-alb"
    }
}