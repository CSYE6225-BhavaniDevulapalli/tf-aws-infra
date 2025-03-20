# Create Security Group for RDS Instance
resource "aws_security_group" "rds_security_group" {
  vpc_id = aws_vpc.my_vpc.id

  # Allow MySQL traffic from the Web App security group ONLY
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id] # Only allow from Web App Security Group
  }

  # Allow outgoing traffic (optional, for database communication)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds_security_group"
  }
}

#Custom parameter group
resource "aws_db_parameter_group" "mysql_parameter_group" {
  family = "mysql8.0"
  name   = "csye6225-mysql"

  tags = {
    Name = "csye6225-mysql-parameter-group"
  }
}


# DB Subnet Group (Private Subnets for RDS)
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = aws_subnet.private_subnet[*].id

  tags = {
    Name = "rds-subnet-group"
  }
}

# Generate a random password for the RDS instance
resource "random_password" "rds_password" {
  length  = var.rds_password_length
  special = false
  upper   = true
  lower   = true
  # Fix: Changed from 'number' to 'numeric' as per the warning
  numeric = true
}

# RDS Instance Configuration
resource "aws_db_instance" "rds_instance" {
  identifier             = var.rds_instance_identifier
  engine                 = var.db_engine
  instance_class         = var.rds_instance_class
  allocated_storage      = var.rds_allocated_storage
  db_name                = var.rds_db_name
  username               = var.rds_username
  password               = random_password.rds_password.result # Using the randomly generated password
  parameter_group_name   = aws_db_parameter_group.mysql_parameter_group.name
  vpc_security_group_ids = [aws_security_group.rds_security_group.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  publicly_accessible    = false # This ensures the RDS instance is not publicly accessible
  skip_final_snapshot    = true

  tags = {
    Name = "csye6225-rds"
  }

  depends_on = [aws_db_subnet_group.rds_subnet_group]
}

resource "aws_secretsmanager_secret" "rds_password_secret" {
  name = "${var.instance_name}-rds-password-secret-${random_id.secret_suffix.hex}"

  tags = {
    Name = "RDSPasswordSecret"
  }
}

resource "random_id" "secret_suffix" {
  byte_length = 4
}

# Create a secret version to store the password in the created secret
resource "aws_secretsmanager_secret_version" "rds_password_version" {
  secret_id = aws_secretsmanager_secret.rds_password_secret.id
  secret_string = jsonencode({
    username = var.rds_username
    password = random_password.rds_password.result
  })
}


# Outputs (Optional, for debugging or reference)
output "rds_password" {
  value     = random_password.rds_password.result
  sensitive = true
}

output "rds_instance_endpoint" {
  value = aws_db_instance.rds_instance.endpoint
}


