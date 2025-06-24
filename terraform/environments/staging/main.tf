# Configuration Terraform pour l'environnement de staging

terraform {
  required_version = ">= 1.0"
  
  backend "s3" {
    bucket = "fizzbuzz-terraform-state-staging"
    key    = "staging/terraform.tfstate"
    region = "eu-west-1"
  }
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
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
      ManagedBy   = "Terraform"
    }
  }
}

# Variables
variable "aws_region" {
  description = "Région AWS"
  type        = string
  default     = "eu-west-1"
}

variable "container_image" {
  description = "Image Docker à déployer"
  type        = string
  default     = "latest"
}

# Data sources pour récupérer le VPC et les sous-réseaux par défaut
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  
  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

# Module Fargate
module "fizzbuzz_staging" {
  source = "../../modules/fargate"
  
  app_name           = "fizzbuzz"
  environment        = "staging"
  container_image    = var.container_image
  container_port     = 3000
  cpu                = 256
  memory             = 512
  desired_count      = 1
  
  vpc_id             = data.aws_vpc.default.id
  private_subnet_ids = data.aws_subnets.default.ids
  public_subnet_ids  = data.aws_subnets.public.ids
}

# Outputs
output "ecr_repository_url" {
  description = "URL du repository ECR pour staging"
  value       = module.fizzbuzz_staging.ecr_repository_url
}

output "load_balancer_dns" {
  description = "DNS du Load Balancer pour staging"
  value       = module.fizzbuzz_staging.load_balancer_dns
}

output "application_url" {
  description = "URL de l'application staging"
  value       = "http://${module.fizzbuzz_staging.load_balancer_dns}"
}

output "ecs_cluster_name" {
  description = "Nom du cluster ECS"
  value       = module.fizzbuzz_staging.ecs_cluster_name
}

output "ecs_service_name" {
  description = "Nom du service ECS"
  value       = module.fizzbuzz_staging.ecs_service_name
}

