# Configuration Terraform pour l'environnement de production (Lambda)

terraform {
  required_version = ">= 1.0"
  
  backend "s3" {
    bucket = "fizzbuzz-terraform-state-production-lambda"
    key    = "production-lambda/terraform.tfstate"
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
      Environment = "production"
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
module "fizzbuzz_production_lambda" {
  source = "../../modules/lambda"
  
  app_name           = "fizzbuzz"
  environment        = "production"
  lambda_runtime     = "nodejs20.x"
  lambda_timeout     = 30
  lambda_memory_size = 512
  source_dir         = "../../../src"
}

# Outputs
output "lambda_function_name" {
  description = "Nom de la fonction Lambda pour production"
  value       = module.fizzbuzz_production_lambda.lambda_function_name
}

output "lambda_function_arn" {
  description = "ARN de la fonction Lambda pour production"
  value       = module.fizzbuzz_production_lambda.lambda_function_arn
}

output "api_gateway_url" {
  description = "URL de l'API Gateway pour production"
  value       = module.fizzbuzz_production_lambda.api_gateway_url
}

output "application_url" {
  description = "URL de l'application production (Lambda)"
  value       = module.fizzbuzz_production_lambda.api_gateway_url
}

output "cloudwatch_log_group" {
  description = "Nom du groupe de logs CloudWatch"
  value       = module.fizzbuzz_production_lambda.cloudwatch_log_group
}

