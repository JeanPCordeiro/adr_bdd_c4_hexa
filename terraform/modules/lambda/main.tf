# Module Terraform pour AWS Lambda

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}

# Variables du module
variable "app_name" {
  description = "Nom de l'application"
  type        = string
}

variable "environment" {
  description = "Environnement (staging, production)"
  type        = string
}

variable "lambda_runtime" {
  description = "Runtime Lambda"
  type        = string
  default     = "nodejs20.x"
}

variable "lambda_timeout" {
  description = "Timeout Lambda en secondes"
  type        = number
  default     = 30
}

variable "lambda_memory_size" {
  description = "Taille mémoire Lambda en MB"
  type        = number
  default     = 256
}

variable "source_dir" {
  description = "Répertoire source de l'application"
  type        = string
  default     = "../../../src"
}

# Données locales
locals {
  name_prefix = "${var.app_name}-${var.environment}"
  
  common_tags = {
    Application = var.app_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Target      = "Lambda"
  }
}

# Création du package Lambda
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = var.source_dir
  output_path = "${path.module}/lambda-package.zip"
  excludes = [
    "index.js",  # Exclure le point d'entrée Express
    "interfaces/fizzbuzz-rest-adapter.js"  # Exclure l'adaptateur REST
  ]
}

# IAM Role pour Lambda
resource "aws_iam_role" "lambda_role" {
  name = "${local.name_prefix}-lambda-role"
  
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
  
  tags = local.common_tags
}

# Politique IAM pour les logs CloudWatch
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${local.name_prefix}-function"
  retention_in_days = 7
  
  tags = local.common_tags
}

# Fonction Lambda
resource "aws_lambda_function" "app" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${local.name_prefix}-function"
  role            = aws_iam_role.lambda_role.arn
  handler         = "lambda.handler"
  runtime         = var.lambda_runtime
  timeout         = var.lambda_timeout
  memory_size     = var.lambda_memory_size
  
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  
  environment {
    variables = {
      NODE_ENV = "production"
      ENVIRONMENT = var.environment
    }
  }
  
  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic_execution,
    aws_cloudwatch_log_group.lambda_logs
  ]
  
  tags = local.common_tags
}

# API Gateway v2 (HTTP API)
resource "aws_apigatewayv2_api" "app" {
  name          = "${local.name_prefix}-api"
  protocol_type = "HTTP"
  description   = "API Gateway pour ${var.app_name} ${var.environment}"
  
  cors_configuration {
    allow_credentials = false
    allow_headers     = ["content-type", "authorization"]
    allow_methods     = ["GET", "POST", "OPTIONS"]
    allow_origins     = ["*"]
    max_age          = 86400
  }
  
  tags = local.common_tags
}

# Stage API Gateway
resource "aws_apigatewayv2_stage" "app" {
  api_id      = aws_apigatewayv2_api.app.id
  name        = var.environment
  auto_deploy = true
  
  default_route_settings {
    throttling_rate_limit  = 1000
    throttling_burst_limit = 2000
  }
  
  tags = local.common_tags
}

# Intégration Lambda avec API Gateway
resource "aws_apigatewayv2_integration" "lambda" {
  api_id           = aws_apigatewayv2_api.app.id
  integration_type = "AWS_PROXY"
  
  connection_type    = "INTERNET"
  description        = "Intégration Lambda pour ${var.app_name}"
  integration_method = "POST"
  integration_uri    = aws_lambda_function.app.invoke_arn
  
  payload_format_version = "2.0"
}

# Routes API Gateway
resource "aws_apigatewayv2_route" "root" {
  api_id    = aws_apigatewayv2_api.app.id
  route_key = "GET /"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_route" "health" {
  api_id    = aws_apigatewayv2_api.app.id
  route_key = "GET /api/health"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_route" "fizzbuzz_get" {
  api_id    = aws_apigatewayv2_api.app.id
  route_key = "GET /api/fizzbuzz/{number}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_route" "fizzbuzz_post" {
  api_id    = aws_apigatewayv2_api.app.id
  route_key = "POST /api/fizzbuzz"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

# Route catch-all pour les autres endpoints
resource "aws_apigatewayv2_route" "default" {
  api_id    = aws_apigatewayv2_api.app.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

# Permission pour API Gateway d'invoquer Lambda
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.app.function_name
  principal     = "apigateway.amazonaws.com"
  
  source_arn = "${aws_apigatewayv2_api.app.execution_arn}/*/*"
}

# Alias Lambda pour le versioning
resource "aws_lambda_alias" "app" {
  name             = var.environment
  description      = "Alias pour l'environnement ${var.environment}"
  function_name    = aws_lambda_function.app.function_name
  function_version = "$LATEST"
}

# Auto Scaling pour Lambda (Provisioned Concurrency si nécessaire)
#resource "aws_lambda_provisioned_concurrency_config" "app" {
#  count                             = var.environment == "production" ? 1 : 0
#  function_name                     = aws_lambda_function.app.function_name
#  provisioned_concurrent_executions = 2
#  qualifier                         = aws_lambda_alias.app.name
#}

# CloudWatch Alarms pour monitoring
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${local.name_prefix}-lambda-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "60"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "This metric monitors lambda errors"
  alarm_actions       = []
  
  dimensions = {
    FunctionName = aws_lambda_function.app.function_name
  }
  
  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "lambda_duration" {
  alarm_name          = "${local.name_prefix}-lambda-duration"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = "60"
  statistic           = "Average"
  threshold           = "10000"  # 10 secondes
  alarm_description   = "This metric monitors lambda duration"
  alarm_actions       = []
  
  dimensions = {
    FunctionName = aws_lambda_function.app.function_name
  }
  
  tags = local.common_tags
}

# Data sources
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# Outputs
output "lambda_function_name" {
  description = "Nom de la fonction Lambda"
  value       = aws_lambda_function.app.function_name
}

output "lambda_function_arn" {
  description = "ARN de la fonction Lambda"
  value       = aws_lambda_function.app.arn
}

output "api_gateway_url" {
  description = "URL de l'API Gateway"
  value       = aws_apigatewayv2_stage.app.invoke_url
}

output "api_gateway_id" {
  description = "ID de l'API Gateway"
  value       = aws_apigatewayv2_api.app.id
}

output "cloudwatch_log_group" {
  description = "Nom du groupe de logs CloudWatch"
  value       = aws_cloudwatch_log_group.lambda_logs.name
}

