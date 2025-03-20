variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
}

variable "aws_profile" {
  description = "AWS CLI profile to use"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "packer_ami_id" {
  type        = string
  description = "ami-0c99431d0fece7f33"
  default     = "ami-0c99431d0fece7f33"
}

variable "instance_type" {
  type        = string
  description = "Instance type for EC2"
  default     = "t2.micro"
}

variable "root_volume_size" {
  type        = number
  description = "Size of the root volume in GB"
  default     = 25
}

variable "root_volume_type" {
  type        = string
  description = "Type of the root volume"
  default     = "gp2"
}

variable "instance_name" {
  type        = string
  description = "Base name for EC2 instances"
  default     = "webapp_ec2"
}

variable "security_group_name" {
  type        = string
  description = "Base name for sg"
  default     = "webapp_securitygroup"
}


variable "SSH_KEY_NAME" {
  type = string
}


# RDS Instance Configuration
variable "rds_instance_identifier" {
  description = "The identifier for the RDS instance"
  default     = "csye6225"
}

variable "rds_db_name" {
  description = "The name of the database"
  default     = "csye6225"
}

variable "rds_username" {
  description = "The master username for the RDS instance"
  default     = "csye6225"
}

variable "db_port" {
  description = "Database port"
  type        = number
  default     = 3306
}

variable "port" {
  description = "Port for the web application"
  type        = number
  default     = 8080
}

variable "rds_allocated_storage" {
  description = "The amount of storage to allocate for the RDS instance"
  default     = 20
}

variable "rds_instance_class" {
  description = "The instance class for the RDS instance"
  default     = "db.t3.micro" # Cheapest instance class
}

variable "rds_password_length" {
  description = "The length of the password to generate"
  default     = 16
}

# MySQL Configuration (You can change it for PostgreSQL or MariaDB if needed)
variable "db_engine" {
  description = "The RDS engine to use (MySQL, PostgreSQL, or MariaDB)"
  default     = "mysql"
}

variable "db_parameter_group_name" {
  description = "Name for the DB parameter group"
  default     = "csye6225-mysql"
}
