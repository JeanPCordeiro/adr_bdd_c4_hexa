# Configuration Terraform pour l'environnement de production

terraform {
  required_version = ">= 1.0"
  
  backend "s3" {
    bucket = "fizzbuzz-terraform-state-production"
    key    = "production/terraform.tfstate"
    region = "us-east-1"
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
      Environment = "production"
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
module "fizzbuzz_production" {
  source = "../../modules/fargate"
  
  app_name           = "fizzbuzz"
  environment        = "production"
  container_image    = var.container_image
  container_port     = 3000
  cpu                = 512
  memory             = 1024
  desired_count      = 2
  
  vpc_id             = data.aws_vpc.default.id
  private_subnet_ids = data.aws_subnets.default.ids
  public_subnet_ids  = data.aws_subnets.public.ids
}

# Outputs
output "ecr_repository_url" {
  description = "URL du repository ECR pour production"
  value       = module.fizzbuzz_production.ecr_repository_url
}

output "load_balancer_dns" {
  description = "DNS du Load Balancer pour production"
  value       = module.fizzbuzz_production.load_balancer_dns
}

output "application_url" {
  description = "URL de l'application production"
  value       = "http://${module.fizzbuzz_production.load_balancer_dns}"
}

output "ecs_cluster_name" {
  description = "Nom du cluster ECS"
  value       = module.fizzbuzz_production.ecs_cluster_name
}

output "ecs_service_name" {
  description = "Nom du service ECS"
  value       = module.fizzbuzz_production.ecs_service_name
}

