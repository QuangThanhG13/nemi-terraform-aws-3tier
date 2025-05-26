# AWS Infrastructure with Terraform

This project implements a complete AWS infrastructure using Terraform, including VPC, EC2 Auto Scaling, RDS PostgreSQL, and Application Load Balancer.

## System Architecture

### Network Layout
- **VPC** (`10.0.0.0/16`):
  - Public subnets: For ALB
  - Private subnets: For EC2 instances
  - Database subnets: For RDS
  - NAT Gateway: Enables internet access for instances in private subnets
  - VPC Endpoints: Allows connection to AWS services without internet access

### Components
1. **Application Load Balancer (ALB)**
   - Located in public subnet
   - Single entry point from the internet
   - Health check path: "/"
   - Port: 80 (HTTP)

2. **EC2 Auto Scaling Group**
   - Located in private subnet
   - Min: 1, Max: 3 instances
   - Using ARM instances (t4g.micro) for cost optimization
   - Auto scaling based on CPU usage (> 70%)
   - Using Amazon Linux 2

3. **RDS PostgreSQL**
   - Located in database subnet
   - PostgreSQL 14
   - Instance class: db.t4g.micro (ARM)
   - Storage: 20GB gp3
   - Backup retention: 7 days
   - Maintenance window: 03:00-04:00 UTC

### Security
1. **Security Groups**
   - ALB: Allows inbound HTTP from internet
   - EC2: Only accepts traffic from ALB
   - RDS: Only allows connections from EC2
   - VPC Endpoints: HTTPS from within VPC

2. **IAM Configuration**
   - EC2 instances use IAM role with:
     - AmazonSSMManagedInstanceCore: Enables SSH via Session Manager
     - Custom policy for RDS access
     - Custom policy for network interface management

## Deployment

### Prerequisites
- Configured AWS CLI
- Installed Terraform
- Session Manager plugin (for SSH)

### Deployment Steps

1. **Initialize Terraform**
   ```bash
   terraform init
   ```

2. **Review Changes**
   ```bash
   terraform plan
   ```

3. **Deploy Infrastructure**
   ```bash
   terraform apply
   ```

### Connecting to Instances

1. **SSH to EC2 via Session Manager**
   ```bash
   aws ssm start-session --target INSTANCE_ID
   ```

2. **Connect to RDS**
   - Only accessible from EC2 instances
   ```bash
   psql -h ENDPOINT -U dbadmin -d myapp
   ```

## Monitoring & Maintenance

### Auto Scaling
- Scales out when CPU > 70%
- Health check every 30 seconds
- Grace period: 180 seconds

### Database
- Backup window: 03:00-04:00 UTC
- Maintenance window: 04:00-05:00 UTC Monday
- Automated backups retained for 7 days

## Clean Up

To remove all infrastructure:
```bash
terraform destroy
```

## Security Best Practices

1. **Network Security**
   - No public IPs for EC2
   - Database only accessible from private subnet
   - VPC endpoints for AWS services

2. **Access Management**
   - Using Session Manager instead of SSH keys
   - Principle of least privilege in IAM policies
   - Secure token requirement for EC2 metadata

## Cost Optimization

1. **Compute**
   - Using ARM instances (t4g.micro)
   - Auto scaling based on demand
   - Spot instances can be considered

2. **Network**
   - Single NAT Gateway
   - VPC endpoints to reduce NAT Gateway costs

## Notes

- This is a basic configuration, may need adjustments for production
- Does not include monitoring stack (CloudWatch, etc.)
- Security groups configured with least privilege principle
- HTTPS and SSL certificates can be added for production 