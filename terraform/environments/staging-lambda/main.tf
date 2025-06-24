# Configuration Terraform pour l'environnement de staging (Lambda)

terraform {
  required_version = ">= 1.0"
  
  backend "s3" {
    bucket = "fizzbuzz-terraform-state-staging-lambda"
    key    = "staging-lambda/terraform.tfstate"
    region = "us-east-1"
  }
  
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

# Configuration du provider AWS
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "FizzBuzz API"
      Environment = "staging"
      Target      = "Lambda"
      ManagedBy   = "Terraform"
    }
  }
}

# Variables
variable "aws_region" {
  description = "Région AWS"
  type        = string
  default     = "us-east-1"
}

# Module Lambda
module "fizzbuzz_staging_lambda" {
  source = "../../modules/lambda"
  
  app_name           = "fizzbuzz"
  environment        = "staging"
  lambda_runtime     = "nodejs20.x"
  lambda_timeout     = 30
  lambda_memory_size = 256
  source_dir         = "../../../src"
}

# Outputs
output "lambda_function_name" {
  description = "Nom de la fonction Lambda pour staging"
  value       = module.fizzbuzz_staging_lambda.lambda_function_name
}

output "lambda_function_arn" {
  description = "ARN de la fonction Lambda pour staging"
  value       = module.fizzbuzz_staging_lambda.lambda_function_arn
}

output "api_gateway_url" {
  description = "URL de l'API Gateway pour staging"
  value       = module.fizzbuzz_staging_lambda.api_gateway_url
}

output "application_url" {
  description = "URL de l'application staging (Lambda)"
  value       = module.fizzbuzz_staging_lambda.api_gateway_url
}

output "cloudwatch_log_group" {
  description = "Nom du groupe de logs CloudWatch"
  value       = module.fizzbuzz_staging_lambda.cloudwatch_log_group
}

