

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Create CloudWatch Log Group
resource "aws_cloudwatch_log_group" "csye6225" {
  name              = "csye6225-log-group"
  retention_in_days = 14
}

# Create CloudWatch Log Stream
resource "aws_cloudwatch_log_stream" "webappLogStream" {
  name           = "webapp-log-stream"
  log_group_name = aws_cloudwatch_log_group.csye6225.name
}

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

# # CloudWatch Agent Server Policy - AWS managed policy for CloudWatch agent
# resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy" {
#   role       = aws_iam_role.ec2_role.name
#   policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
# }

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

# CloudWatch Agent Policy - Allows EC2 instance to interact with CloudWatch for logs and metrics
resource "aws_iam_policy" "cloudwatch_policy" {
  name        = "${var.instance_name}-cloudwatch-policy"
  description = "Policy allowing EC2 instance to send logs and metrics to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "cloudwatch:PutMetricData"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = "logs:PutLogEvents"
        Effect   = "Allow"
        Resource = "${aws_cloudwatch_log_group.csye6225.arn}:*"
      }
    ]
  })
}


resource "aws_iam_policy" "secretsmanager_policy" {
  name        = "${var.instance_name}-secretsmanager-policy"
  description = "Policy allowing EC2 instance to retrieve the RDS password from Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Effect   = "Allow"
        Resource = aws_secretsmanager_secret.rds_password_secret.arn
      }
    ]
  })
}

# Attach the policy to the EC2 Role
resource "aws_iam_role_policy_attachment" "secretsmanager_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.secretsmanager_policy.arn
}

# Attach CloudWatch custom policy to EC2 role
resource "aws_iam_role_policy_attachment" "cloudwatch_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.cloudwatch_policy.arn
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
# resource "aws_iam_role_policy_attachment" "ssm_parameter_attachment" {
#   role       = aws_iam_role.ec2_role.name
#   policy_arn = aws_iam_policy.ssm_parameter_policy.arn
# }

# Attach AWS managed policy for CloudWatch Agent
# resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy" {
#   role       = aws_iam_role.ec2_role.name
#   policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
# }