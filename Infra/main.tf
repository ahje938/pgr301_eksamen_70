terraform {
  required_version = ">= 1.9.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.74.0"
    }
  }

  backend "s3" {
    bucket         = "pgr301-2024-terraform-state"
    key            = "70/terraform.tfstate"    
    region         = "eu-west-1"
    encrypt        = true
  }
}

provider "aws" {
  region = "eu-west-1"
}

# SQS Queue
resource "aws_sqs_queue" "image_processing_queue_70" {
  name                        = "image-processing-queue-70"
  visibility_timeout_seconds  = 60
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role_eksamen70" {
  name = "lambda-sqs-role-eksamen70"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for Lambda
resource "aws_iam_policy" "lambda_sqs_policy_eksamen70" {
  name = "lambda-sqs-policy-eksamen70"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = "${aws_sqs_queue.image_processing_queue_70.arn}"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject"
        ]
        Resource = "arn:aws:s3:::pgr301-couch-explorers/*"
      },
      {
        Effect = "Allow"
        Action = "logs:*"
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = "bedrock:InvokeModel"
        Resource = "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-image-generator-v1"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:PassRole",
          "iam:GetRole",
          "iam:ListRolePolicies",
          "iam:GetRolePolicy"
        ]
        Resource = "arn:aws:iam::*:role/*"
      }
    ]
  })
}

# Attach Policy to Role
resource "aws_iam_role_policy_attachment" "attach_policy_eksamen70" {
  role       = aws_iam_role.lambda_role_eksamen70.name
  policy_arn = aws_iam_policy.lambda_sqs_policy_eksamen70.arn
}

# Lambda Function
resource "aws_lambda_function" "lambda_sqs_processor_eksamen70" {
  function_name = "sqs-image-processor-eksamen70"
  runtime       = "python3.9"
  handler       = "lambda_sqs.lambda_handler"
  role          = aws_iam_role.lambda_role_eksamen70.arn
  timeout       = 30

  filename         = "lambda_sqs.zip"
  source_code_hash = filebase64sha256("lambda_sqs.zip")

  environment {
    variables = {
      BUCKET_NAME   = "pgr301-couch-explorers"
      SQS_QUEUE_URL = aws_sqs_queue.image_processing_queue_70.url
    }
  }

  depends_on = [aws_iam_role_policy_attachment.attach_policy_eksamen70]
}

# Event Source Mapping
resource "aws_lambda_event_source_mapping" "sqs_to_lambda_eksamen70" {
  event_source_arn = aws_sqs_queue.image_processing_queue_70.arn
  function_name    = aws_lambda_function.lambda_sqs_processor_eksamen70.arn
  batch_size       = 10
  enabled          = true
}

# Variabel for e-postadresse
variable "email" {
  description = "email som mottar varsel"
  type        = string
}


resource "aws_sns_topic" "sqs_delay_alarm_topic" {
  name = "sqs-delay-alarm-topic"
}

# SNS Subscription for e-post
resource "aws_sns_topic_subscription" "sqs_delay_alarm_subscription" {
  topic_arn = aws_sns_topic.sqs_delay_alarm_topic.arn
  protocol  = "email"
  endpoint  = var.email
}


resource "aws_cloudwatch_metric_alarm" "sqs_age_of_oldest_message_alarm" {
  alarm_name                = "SQS-Age-Of-Oldest-Message-Alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "ApproximateAgeOfOldestMessage"
  namespace                 = "AWS/SQS"
  period                    = 60
  statistic                 = "Maximum"
  threshold                 = 300 
  alarm_description         = "alarm hvis 300s overgås"
  dimensions = {
    QueueName = aws_sqs_queue.image_processing_queue_70.name
  }

  alarm_actions = [aws_sns_topic.sqs_delay_alarm_topic.arn]
}

#