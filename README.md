
**Infrastructure Setup Using Terraform**

This document provides a comprehensive guide to setting up AWS infrastructure using **Terraform**.


## ** Prerequisites**
Before proceeding, ensure you have the following tools installed:

Terraform: Install Terraform https://developer.hashicorp.com/terraform/install

AWS CLI: Install AWS CLI https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html

configure it by running:  aws configure

Valid AWS profiles set up in the AWS CLI for Terraform to use:

- dev profile

- demo profile

we will need to generate access keys with sufficient permissions to create AWS resources.

**Infrastructure Setup**

This Terraform configuration will set up the following AWS resources:

- A VPC

- 3 Public Subnets (one in each availability zone)

- 3 Private Subnets (one in each availability zone)

- An Internet Gateway attached to the VPC

- A Public Route Table with a route to the Internet Gateway for the public subnets

- A Private Route Table for the private subnets

- Associations between route tables and subnets

**Note**:

- Availability zones will be fetched dynamically.

- The CIDR blocks for subnets will be calculated dynamically based on the available zones.

**Clone the Repository**

Clone the repository to your local machine:

git clone https://github.com/CSYE6225-BhavaniDevulapalli/tf-aws-infra/tree/main

- cd tf-aws-infra

- Create a .tfvars File

You will need to create a .tfvars file to define the required variables. 

aws_region = ""

aws_profile=""

vpc_cidr = ""

public_subnet_cidrs = [
 
]

private_subnet_cidrs = [
  
]

vpc_name = ""

All these values defines the AWS region, the VPC CIDR block, the public and private subnets, and the name of the VPC that will be created in the aws.

**Initialize Terraform**

Run the following command to initialize Terraform. This will download the necessary provider plugins and set up your working directory:

- terraform init

**Review the Plan**

Run the following command to see what resources will be created without actually applying any changes:

- terraform plan -var-file="tfvarsfile"

This command will display a list of actions Terraform plans to perform. Review this list to ensure everything looks correct.

**Apply the Terraform Plan**

If everything looks good in the plan, apply the changes to provision the infrastructure:

- terraform apply -var-file="tfvarsfile"

You will be prompted to confirm the action by typing yes.

**Verify the Infrastructure**

Once the apply process completes, Terraform will output the details of the created infrastructure (e.g., VPC, subnet, routes etc). 

**Destroying the Infrastructure**

When you're finished with the infrastructure use the following command to destroy the infrastruture if needed

- terraform destroy