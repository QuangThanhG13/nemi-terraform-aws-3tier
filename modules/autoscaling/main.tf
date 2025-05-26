data "aws_ami" "ami" { 
    most_recent = true 

    filter { 
        name = "name" 
        values = ["amzn2-ami-hvm-2.0.*-arm64-gp2"]
    }

    owners = ["amazon"]
}

resource "aws_iam_instance_profile" "web" {
    name_prefix = "web-"
    role = aws_iam_role.web.name
}

resource "aws_iam_role" "web" {
    name_prefix = "web-"
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
}

resource "aws_iam_role_policy_attachment" "ssm" {
    role = aws_iam_role.web.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "ec2_permissions" {
    name = "ec2-permissions"
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
    key_name_prefix = "web-"
    public_key = file("${path.module}/web.pub")
}

resource "aws_launch_template" "web" { 
    name_prefix = "web-"
    image_id = data.aws_ami.ami.id
    instance_type = "t4g.micro"

    iam_instance_profile {
        name = aws_iam_instance_profile.web.name
    }

    network_interfaces {
        associate_public_ip_address = false
        security_groups = [var.sg.web.id]
    }

    user_data = filebase64("${path.module}/run.sh")

    metadata_options {
        http_endpoint = "enabled"
        http_tokens = "required"
    }
}

data "aws_region" "current" {}

resource "aws_autoscaling_group" "web" { 
    name = "${var.project}-asg" 
    min_size = 1
    max_size = 3
    desired_capacity = 1
    vpc_zone_identifier = var.vpc.private_subnets
    target_group_arns = module.alb.target_group_arns
    health_check_type = "ELB"
    health_check_grace_period = 180

    launch_template {
        id = aws_launch_template.web.id
        version = aws_launch_template.web.latest_version
    }

    tag {
        key = "Name"
        value = "${var.project}-web"
        propagate_at_launch = true
    }
}

resource "aws_autoscaling_policy" "cpu_policy" {
    name = "${var.project}-cpu-policy"
    autoscaling_group_name = aws_autoscaling_group.web.name
    policy_type = "TargetTrackingScaling"

    target_tracking_configuration {
        predefined_metric_specification {
            predefined_metric_type = "ASGAverageCPUUtilization"
        }
        target_value = 70.0
    }
}

module "alb" {
    source = "terraform-aws-modules/alb/aws"
    version = "~> 8.0"

    name = var.project

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
                interval = 30
                path = "/"
                port = "traffic-port"
                healthy_threshold = 2
                unhealthy_threshold = 2
                timeout = 5
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
}