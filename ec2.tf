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

  # Add the IAM instance profile
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

# Start application
sudo systemctl start my_webapp_service
EOF
)
  tags = {
    Name = var.instance_name
  }
  
  depends_on = [aws_internet_gateway.igw, aws_security_group.app_sg, aws_db_instance.rds_instance]
}






# resource "aws_instance" "webapp_ec2" {
#   ami                         = var.packer_ami_id
#   instance_type               = var.instance_type
#   subnet_id                   = aws_subnet.public_subnet[0].id
#   vpc_security_group_ids      = [aws_security_group.app_sg.id]
#   associate_public_ip_address = true
#   key_name                    = var.SSH_KEY_NAME

#   root_block_device {
#     volume_size           = var.root_volume_size
#     volume_type           = var.root_volume_type
#     delete_on_termination = true
#   }

#   disable_api_termination = false

#   tags = {
#     Name = var.instance_name
#   }

#   depends_on = [aws_internet_gateway.igw, aws_security_group.app_sg]
# }