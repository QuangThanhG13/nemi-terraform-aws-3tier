#!/bin/bash
yum update -y
yum install -y httpd

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

## update and install docker
sudo yum update -y
sudo yum install -y docker 

# start docker
sudo systemctl start docker
sudo systemctl enable docker

# add ec2-user to docker group
sudo usermod -aG docker ec2-user

# Create a simple web page
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Hello World</title>
</head>
<body>
    <h1>Hello from EC2</h1>
</body>
</html>
EOF

# Create health check endpoint
echo "OK" > /var/www/html/health

# Set proper permissions
chmod 644 /var/www/html/index.html /var/www/html/health
chown apache:apache /var/www/html/index.html /var/www/html/health

# Ensure Apache is running
systemctl restart httpd