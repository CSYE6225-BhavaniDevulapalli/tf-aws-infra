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
