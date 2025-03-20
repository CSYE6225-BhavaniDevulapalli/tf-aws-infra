# # EC2 Role - Allows EC2 to assume this role
# resource "aws_iam_role" "ec2_role" {
#   name = "${var.instance_name}-ec2-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         }
#       }
#     ]
#   })

#   tags = {
#     Name = "${var.instance_name}-ec2-role"
#   }
# }

# # S3 Access Policy - Allows EC2 to interact with the S3 bucket
# resource "aws_iam_policy" "s3_access_policy" {
#   name        = "${var.instance_name}-s3-access-policy"
#   description = "Policy allowing EC2 instance to access S3 bucket"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = [
#           "s3:GetObject",
#           "s3:PutObject",
#           "s3:DeleteObject",
#           "s3:ListBucket"
#         ]
#         Effect = "Allow"
#         Resource = [
#           "${aws_s3_bucket.webapp_bucket.arn}",
#           "${aws_s3_bucket.webapp_bucket.arn}/*"
#         ]
#       }
#     ]
#   })
# }


# # Secrets Manager Policy - Allows EC2 to retrieve secrets (if needed)
# resource "aws_iam_policy" "secrets_manager_policy" {
#   name        = "${var.instance_name}-secrets-manager-policy"
#   description = "Policy allowing EC2 instance to access Secrets Manager"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = [
#           "secretsmanager:GetSecretValue"
#         ]
#         Effect   = "Allow"
#         Resource = aws_secretsmanager_secret.rds_password_secret.arn
#       }
#     ]
#   })
# }

# # SSM Parameter Store Policy - An alternative to Secrets Manager for configuration
# resource "aws_iam_policy" "ssm_parameter_policy" {
#   name        = "${var.instance_name}-ssm-parameter-policy"
#   description = "Policy allowing EC2 instance to access SSM Parameter Store"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = [
#           "ssm:GetParameter",
#           "ssm:GetParameters",
#           "ssm:GetParametersByPath"
#         ]
#         Effect   = "Allow"
#         Resource = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.instance_name}/*"
#       }
#     ]
#   })
# }

# # Attach policies to role
# resource "aws_iam_role_policy_attachment" "s3_policy_attachment" {
#   role       = aws_iam_role.ec2_role.name
#   policy_arn = aws_iam_policy.s3_access_policy.arn
# }



# resource "aws_iam_role_policy_attachment" "secrets_manager_attachment" {
#   role       = aws_iam_role.ec2_role.name
#   policy_arn = aws_iam_policy.secrets_manager_policy.arn
# }

# resource "aws_iam_role_policy_attachment" "ssm_parameter_attachment" {
#   role       = aws_iam_role.ec2_role.name
#   policy_arn = aws_iam_policy.ssm_parameter_policy.arn
# }

# # Create instance profile for EC2
# resource "aws_iam_instance_profile" "ec2_instance_profile" {
#   name = "${var.instance_name}-ec2-instance-profile"
#   role = aws_iam_role.ec2_role.name
# }

# # Data sources to get account ID and region
# data "aws_caller_identity" "current" {}
# data "aws_region" "current" {}


# EC2 Role - Allows EC2 to assume this role
# Data sources to get account ID and region
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# resource "aws_iam_policy" "demo_user_permissions" {
#   name        = "DemoUserPermissions"
#   description = "Policy granting necessary permissions to create IAM roles, policies, and manage resources."

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect   = "Allow"
#         Action   = [
#           "iam:CreateRole",
#           "iam:CreatePolicy",
#           "iam:AttachRolePolicy",
#           "iam:PassRole",
#           "rds:CreateDBParameterGroup",
#           "rds:CreateDBSubnetGroup",
#           "secretsmanager:CreateSecret"
#         ]
#         Resource = "*"
#       }
#     ]
#   })
# }

# resource "aws_iam_user_policy_attachment" "attach_policy_to_demo_user" {
#   user       = "demo-user"  # Make sure to replace this with the actual IAM user name
#   policy_arn = aws_iam_policy.demo_user_permissions.arn
# }

# EC2 Role - Allows EC2 to assume this role
# Define the EC2 Role
resource "aws_iam_role" "ec2_role" {
  name = "${var.instance_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.instance_name}-ec2-role"
  }
}

# EC2 General Permissions Policy
resource "aws_iam_policy" "ec2_general_policy" {
  name        = "${var.instance_name}-ec2-general-policy"
  description = "Policy allowing EC2 instance to interact with AWS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeImages",
          "ec2:RunInstances",
          "ec2:CreateTags",
          "ec2:TerminateInstances"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Attach EC2 General Permissions to the EC2 Role
resource "aws_iam_role_policy_attachment" "ec2_general_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_general_policy.arn
}

# S3 Access Policy - Allows EC2 to interact with the S3 bucket
resource "aws_iam_policy" "s3_access_policy" {
  name        = "${var.instance_name}-s3-access-policy"
  description = "Policy allowing EC2 instance to access S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Effect = "Allow"
        Resource = [
          "${aws_s3_bucket.webapp_bucket.arn}",
          "${aws_s3_bucket.webapp_bucket.arn}/*"
        ]
      }
    ]
  })
}

# SSM Parameter Store Policy - Allows EC2 to access SSM Parameter Store
resource "aws_iam_policy" "ssm_parameter_policy" {
  name        = "${var.instance_name}-ssm-parameter-policy"
  description = "Policy allowing EC2 instance to access SSM Parameter Store"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.instance_name}/*"
      }
    ]
  })
}

# Create Instance Profile for EC2
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.instance_name}-ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}

# Attach S3 Access Policy to EC2 Role
resource "aws_iam_role_policy_attachment" "s3_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

# Attach SSM Parameter Store Policy to EC2 Role
resource "aws_iam_role_policy_attachment" "ssm_parameter_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ssm_parameter_policy.arn
}
