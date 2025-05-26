# AWS Infrastructure with Terraform

## Hi everyone, I’m QThanh. This is my first attempt at using Terraform for Infrastructure as Code, so please feel free to share any feedback or point out anything I can improve. Thank you! 

This project including VPC, EC2 Auto Scaling, RDS PostgreSQL, and Application Load Balancer.

## System Architecture
### AWS Architecture Diagram (Nemi)
<img width="836" alt="image" src="https://github.com/user-attachments/assets/6f552a00-223d-4d2a-8c78-a9c91446de7d" />

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
✅ Configured AWS CLI
```bash
export AWS_ACCESS_KEY_ID=....
export AWS_SECRET_ACCESS_KEY=...
export AWS_REGION=...
```
✅ Installed Terraform for mac 
```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

✅ Session Manager Plugin (for SSH)
This plugin works in conjunction with:

- **AWS CLI**
- **SSH configuration** (already set up in your `~/.ssh/config` file)
- **IAM permissions** (configured via Terraform)
- **VPC Endpoints** (configured in the networking module)

To install it on **macOS**, use Homebrew:

```bash
brew install --cask session-manager-plugin
```

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
-> Succesfull : 
<img width="888" alt="image" src="https://github.com/user-attachments/assets/c9314f97-1239-4a53-bb32-96d43570ac77" />

### Connecting to Instances

1. **Find Instance id of EC2**
  <img width="1536" alt="image" src="https://github.com/user-attachments/assets/a66b006b-25ce-4a72-a186-f6b1b2758808" />

1. **SSH to EC2 via Session Manager**
   ```bash
   aws ssm start-session --target INSTANCE_ID
   ```
   <img width="550" alt="image" src="https://github.com/user-attachments/assets/cbfe8867-485c-4974-8dfc-362b889759ec" />

2. **Connect to RDS**
   - Install psql
    ```bash
     sudo yum install postgresql15 -y
    ```
    
   - Only accessible from EC2 instances
   ```bash
   psql -h ENDPOINT -U dbadmin -d myapp
   ```
   <img width="811" alt="image" src="https://github.com/user-attachments/assets/f75a8083-d42e-4107-bec8-51805244a413" />

## Monitoring & Maintenance
- To test ASG I used:
```bash
hey -z 300s -c 100 <IP_server>
```
<img width="828" alt="image" src="https://github.com/user-attachments/assets/50f4c445-4a80-4fff-9ab8-0acaf2daf951" />

- Initially there was only 1 ec2 like this :
  <img width="1508" alt="image" src="https://github.com/user-attachments/assets/71586f04-a465-47e3-8d9f-d72b1bbf1e44" />

- After running the test command, it will scale up to 2 more :
  


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
