
resource "aws_launch_template" "webapp_lt" {
  name          = "webapp-launch_template"
  image_id      = var.packer_ami_id
  instance_type = var.instance_type
  key_name      = var.SSH_KEY_NAME

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.app_sg.id]
  }


  user_data = base64encode(<<EOF
#!/bin/bash
LOG_FILE="/opt/csye6225/user-data-log.txt"
echo "Running user data script..." > $LOG_FILE

# Create .env file for application
APP_DIR="/opt/csye6225/webapp"
mkdir -p $APP_DIR
cd $APP_DIR

# # Retrieve DB password from AWS Secrets Manager
# echo "Retrieving database password from Secrets Manager..." >> $LOG_FILE
# SECRET_NAME="${aws_secretsmanager_secret.rds_password_secret.name}"
# DB_CREDS=$(aws secretsmanager get-secret-value \
#   --secret-id "$SECRET_NAME" \
#   --region "${var.aws_region}" \
#   --query 'SecretString' \
#   --output text)

# # Extract username and password from the JSON
# DB_USERNAME=$(echo $DB_CREDS | jq -r '.username')
# DB_PASSWORD=$(echo $DB_CREDS | jq -r '.password')

# if [ -z "$DB_PASSWORD" ]; then
#   echo "ERROR: Failed to retrieve database password from Secrets Manager" >> $LOG_FILE
#   exit 1
# fi

# echo "Successfully retrieved database credentials" >> $LOG_FILE


# Check if AWS CLI is installed
echo "Checking AWS CLI installation..." >> $LOG_FILE
if ! command -v aws &> /dev/null; then
    echo "ERROR: AWS CLI is not installed!" >> $LOG_FILE
    exit 1
fi

echo "AWS CLI is installed: $(aws --version)" >> $LOG_FILE

# Retrieve DB password from AWS Secrets Manager
echo "Retrieving database password from Secrets Manager..." >> $LOG_FILE
SECRET_NAME="${aws_secretsmanager_secret.rds_password_secret.name}"
echo "Secret name: $SECRET_NAME" >> $LOG_FILE

# Run the AWS CLI command with verbose debug output
echo "Running AWS CLI command to get secret..." >> $LOG_FILE
DB_CREDS=$(aws secretsmanager get-secret-value \
  --secret-id "$SECRET_NAME" \
  --region "${var.aws_region}" \
  --query 'SecretString' \
  --output text --debug 2>> $LOG_FILE)

# Check if command was successful
if [ $? -ne 0 ]; then
    echo "ERROR: AWS CLI command failed!" >> $LOG_FILE
    exit 1
fi

# Log success (without revealing actual password)
echo "AWS CLI command successful. Retrieved credentials." >> $LOG_FILE

# Extract username and password from the JSON
echo "Parsing JSON response..." >> $LOG_FILE
DB_USERNAME=$(echo $DB_CREDS | jq -r '.username')
DB_PASSWORD=$(echo $DB_CREDS | jq -r '.password')

if [ -z "$DB_PASSWORD" ]; then
  echo "ERROR: Failed to parse database password from secret" >> $LOG_FILE
  exit 1
fi



echo "DB_HOST='${replace(aws_db_instance.rds_instance.endpoint, ":3306", "")}'" >> .env
echo "DB_PORT='${var.db_port}'" >> .env
# echo "DB_USER='${var.rds_username}'" >> .env
echo "DB_USER='$DB_USERNAME'" >> .env
# echo "DB_PASSWORD='${random_password.rds_password.result}'" >> .env
# echo "DB_PASSWORD='${local.db_password}'" >> .env
echo "DB_PASSWORD='$DB_PASSWORD'" >> .env
echo "DB_NAME='${var.rds_db_name}'" >> .env
echo "S3_BUCKET_NAME='${aws_s3_bucket.webapp_bucket.id}'" >> .env
echo "AWS_REGION='${var.aws_region}'" >> .env
echo "PORT='${var.port}'" >> .env

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
    "namespace": "${var.metrics_namespace}",
    "metrics_collected": {
      "statsd": {
        "service_address": ":8125",
        "metrics_collection_interval": 10
      },
      "cpu": {
          "measurement": ["cpu_usage_idle", "cpu_usage_user", "cpu_usage_system"],
          "metrics_collection_interval": 60
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

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.root_volume_size
      volume_type           = var.root_volume_type
      delete_on_termination = true
      encrypted             = true
      kms_key_id            = aws_kms_key.ec2_key.arn
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = var.instance_name
    }
  }
}
