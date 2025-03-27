

# EC2 Instance Resource
resource "aws_instance" "webapp_ec2" {
  ami                         = var.packer_ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_subnet[0].id
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  associate_public_ip_address = true
  key_name                    = var.SSH_KEY_NAME

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    delete_on_termination = true
  }

  # Attach IAM Instance Profile
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  disable_api_termination = false

  # Base64 encoding of the user data script
  user_data = base64encode(<<EOF
#!/bin/bash
LOG_FILE="/opt/csye6225/user-data-log.txt"
echo "Running user data script..." > $LOG_FILE

# Create .env file for application
APP_DIR="/opt/csye6225/webapp"
mkdir -p $APP_DIR
cd $APP_DIR

echo "DB_HOST='${replace(aws_db_instance.rds_instance.endpoint, ":3306", "")}'" >> .env
echo "DB_PORT='${var.db_port}'" >> .env
echo "DB_USER='${var.rds_username}'" >> .env
echo "DB_PASSWORD='${random_password.rds_password.result}'" >> .env
echo "DB_NAME='${var.rds_db_name}'" >> .env
echo "S3_BUCKET_NAME='${aws_s3_bucket.webapp_bucket.id}'" >> .env
echo "AWS_REGION='${var.aws_region}'" >> .env
echo "PORT='${var.port}'" >> .env

# Install CloudWatch agent
# sudo yum update -y
# sudo yum install -y amazon-cloudwatch-agent

# Create CloudWatch agent config
sudo mkdir -p /opt/aws/amazon-cloudwatch-agent/etc
sudo tee /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json > /dev/null << EOT
{
  "agent": {
    "metrics_collection_interval": 10,
    "logfile": "/var/log/amazon-cloudwatch-agent.log"
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/opt/csye6225/webapp/logs/webapp-*.log",
            "log_group_name": "csye6225-log-group",
            "log_stream_name": "webapp-log-stream",
            "timestamp_format": "%Y-%m-%d %H:%M:%S"
          }
        ]
      }
    }
  },
  "metrics": {
    "namespace": "metrics-webapp",
    "metrics_collected": {
      "statsd": {
        "service_address": ":8125",
        "metrics_collection_interval": 10
      },
      "disk": {
        "measurement": ["used_percent"],
        "metrics_collection_interval": 60,
        "resources": ["*"]
      },
      "mem": {
        "measurement": ["mem_used_percent"],
        "metrics_collection_interval": 60
      }
    }
  }
}

EOT

# Debug: Check if JSON file is created properly
ls -l /opt/aws/amazon-cloudwatch-agent/etc/ >> $LOG_FILE
cat /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json >> $LOG_FILE

# Start CloudWatch agent with the config
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a start \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
  -m ec2

# Enable & Restart CloudWatch agent
sudo systemctl enable amazon-cloudwatch-agent
sudo systemctl restart amazon-cloudwatch-agent

# Start application service
sudo systemctl start my_webapp_service

echo "User data script completed." >> $LOG_FILE
EOF
  )

  tags = {
    Name = var.instance_name
  }

  depends_on = [aws_internet_gateway.igw, aws_security_group.app_sg, aws_db_instance.rds_instance, aws_cloudwatch_log_group.csye6225]
}
