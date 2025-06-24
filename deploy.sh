#!/bin/bash

# Script de déploiement pour AWS Fargate ou Lambda
# Usage: ./deploy.sh [staging|production] [fargate|lambda]

set -e

# Fonction pour afficher l'aide
show_help() {
    echo "Usage: $0 [ENVIRONMENT] [TARGET]"
    echo ""
    echo "ENVIRONMENT:"
    echo "  staging     Déploiement en environnement de staging (défaut)"
    echo "  production  Déploiement en environnement de production"
    echo ""
    echo "TARGET:"
    echo "  fargate     Déploiement sur AWS Fargate (défaut)"
    echo "  lambda      Déploiement sur AWS Lambda"
    echo ""
    echo "Exemples:"
    echo "  $0                          # staging + fargate"
    echo "  $0 staging fargate          # staging + fargate"
    echo "  $0 staging lambda           # staging + lambda"
    echo "  $0 production fargate       # production + fargate"
    echo "  $0 production lambda        # production + lambda"
    echo ""
    echo "Variables d'environnement:"
    echo "  AWS_REGION                  # Région AWS (défaut: us-east-1)"
}

# Gestion des arguments d'aide
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

ENVIRONMENT=${1:-staging}
TARGET=${2:-fargate}
AWS_REGION=${AWS_REGION:-us-east-1}
APP_NAME="fizzbuzz"

echo "🚀 Déploiement de l'API FizzBuzz"
echo "Environnement: $ENVIRONMENT"
echo "Cible: $TARGET"
echo "Région AWS: $AWS_REGION"

# Validation des paramètres
if [[ ! "$ENVIRONMENT" =~ ^(staging|production)$ ]]; then
    echo "❌ Environnement invalide. Utilisez 'staging' ou 'production'."
    exit 1
fi

if [[ ! "$TARGET" =~ ^(fargate|lambda)$ ]]; then
    echo "❌ Cible invalide. Utilisez 'fargate' ou 'lambda'."
    exit 1
fi

# Vérification des prérequis
command -v aws >/dev/null 2>&1 || { echo "❌ AWS CLI est requis mais non installé."; exit 1; }
command -v terraform >/dev/null 2>&1 || { echo "❌ Terraform est requis mais non installé."; exit 1; }

if [[ "$TARGET" == "fargate" ]]; then
    command -v docker >/dev/null 2>&1 || { echo "❌ Docker est requis pour le déploiement Fargate."; exit 1; }
fi

# Vérification de la connexion AWS
echo "🔐 Vérification des credentials AWS..."
aws sts get-caller-identity > /dev/null || { echo "❌ Credentials AWS non configurés."; exit 1; }

# Fonction pour déployer sur Fargate
deploy_fargate() {
    echo "🐳 Déploiement sur AWS Fargate..."
    
    # Construction de l'image Docker
    echo "🔨 Construction de l'image Docker..."
    docker build -t $APP_NAME:latest .
    
    # Répertoire Terraform pour Fargate
    TERRAFORM_DIR="terraform/environments/$ENVIRONMENT"
    
    if [[ ! -d "$TERRAFORM_DIR" ]]; then
        echo "❌ Répertoire Terraform non trouvé: $TERRAFORM_DIR"
        exit 1
    fi
    
    cd "$TERRAFORM_DIR"
    
    # Initialisation de Terraform
    echo "🏗️ Initialisation de Terraform..."
    terraform init
    
    # Application de l'infrastructure
    echo "📋 Planification de l'infrastructure..."
    terraform plan -out=tfplan
    
    echo "🚀 Application de l'infrastructure..."
    terraform apply tfplan
    
    # Récupération de l'URL ECR
    ECR_URL=$(terraform output -raw ecr_repository_url)
    IMAGE_TAG=$(git rev-parse --short HEAD 2>/dev/null || echo "latest")
    
    echo "📤 Push de l'image vers ECR..."
    
    # Connexion à ECR
    aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_URL
    
    # Tag et push de l'image
    docker tag $APP_NAME:latest $ECR_URL:$IMAGE_TAG
    docker tag $APP_NAME:latest $ECR_URL:latest
    
    docker push $ECR_URL:$IMAGE_TAG
    docker push $ECR_URL:latest
    
    # Mise à jour du service ECS
    echo "🔄 Mise à jour du service ECS..."
    CLUSTER_NAME=$(terraform output -raw ecs_cluster_name)
    SERVICE_NAME=$(terraform output -raw ecs_service_name)
    
    aws ecs update-service \
        --cluster $CLUSTER_NAME \
        --service $SERVICE_NAME \
        --force-new-deployment \
        --region $AWS_REGION
    
    echo "⏳ Attente de la stabilité du déploiement..."
    aws ecs wait services-stable \
        --cluster $CLUSTER_NAME \
        --services $SERVICE_NAME \
        --region $AWS_REGION
    
    # Récupération de l'URL de l'application
    APP_URL=$(terraform output -raw application_url)
    
    echo "✅ Déploiement Fargate terminé avec succès!"
    echo "🌐 URL de l'application: $APP_URL"
    echo "🏥 Health check: $APP_URL/api/health"
    echo "📊 Monitoring: https://console.aws.amazon.com/ecs/home?region=$AWS_REGION#/clusters/$CLUSTER_NAME/services"
    
    cd - > /dev/null
}

# Fonction pour déployer sur Lambda
deploy_lambda() {
    echo "⚡ Déploiement sur AWS Lambda..."
    
    # Répertoire Terraform pour Lambda
    TERRAFORM_DIR="terraform/environments/$ENVIRONMENT-lambda"
    
    if [[ ! -d "$TERRAFORM_DIR" ]]; then
        echo "❌ Répertoire Terraform non trouvé: $TERRAFORM_DIR"
        exit 1
    fi
    
    cd "$TERRAFORM_DIR"
    
    # Initialisation de Terraform
    echo "🏗️ Initialisation de Terraform..."
    terraform init
    
    # Application de l'infrastructure
    echo "📋 Planification de l'infrastructure..."
    terraform plan -out=tfplan
    
    echo "🚀 Application de l'infrastructure..."
    terraform apply tfplan
    
    # Récupération des informations de déploiement
    FUNCTION_NAME=$(terraform output -raw lambda_function_name)
    APP_URL=$(terraform output -raw application_url)
    LOG_GROUP=$(terraform output -raw cloudwatch_log_group)
    
    echo "✅ Déploiement Lambda terminé avec succès!"
    echo "⚡ Fonction Lambda: $FUNCTION_NAME"
    echo "🌐 URL de l'application: $APP_URL"
    echo "🏥 Health check: $APP_URL/api/health"
    echo "📊 Logs: https://console.aws.amazon.com/cloudwatch/home?region=$AWS_REGION#logsV2:log-groups/log-group/${LOG_GROUP//\//%2F}"
    
    cd - > /dev/null
}

# Fonction pour les tests de fumée
run_smoke_tests() {
    local app_url=$1
    
    echo "🧪 Exécution des tests de fumée..."
    sleep 10  # Attendre que l'application soit prête
    
    # Test de santé
    #if curl -f "$app_url/api/health" > /dev/null 2>&1; then
    #    echo "✅ Health check réussi"
    #else
    #    echo "❌ Health check échoué"
    #    return 1
    #fi
    
    # Test FizzBuzz
    if curl -f "$app_url/api/fizzbuzz/15" | grep -q "FizzBuzz"; then
        echo "✅ Test FizzBuzz réussi"
    else
        echo "❌ Test FizzBuzz échoué"
        return 1
    fi
    
    # Test POST
    if curl -f -X POST -H "Content-Type: application/json" -d '{"number": 9}' "$app_url/api/fizzbuzz" | grep -q "Fizz"; then
        echo "✅ Test POST FizzBuzz réussi"
    else
        echo "❌ Test POST FizzBuzz échoué"
        return 1
    fi
    
    echo "🎉 Tous les tests de fumée ont réussi!"
}

# Fonction pour afficher l'aide
show_help() {
    echo "Usage: $0 [ENVIRONMENT] [TARGET]"
    echo ""
    echo "ENVIRONMENT:"
    echo "  staging     Déploiement en environnement de staging (défaut)"
    echo "  production  Déploiement en environnement de production"
    echo ""
    echo "TARGET:"
    echo "  fargate     Déploiement sur AWS Fargate (défaut)"
    echo "  lambda      Déploiement sur AWS Lambda"
    echo ""
    echo "Exemples:"
    echo "  $0                          # staging + fargate"
    echo "  $0 staging fargate          # staging + fargate"
    echo "  $0 staging lambda           # staging + lambda"
    echo "  $0 production fargate       # production + fargate"
    echo "  $0 production lambda        # production + lambda"
    echo ""
    echo "Variables d'environnement:"
    echo "  AWS_REGION                  # Région AWS (défaut: us-east-1)"
}

# Gestion des arguments d'aide
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

# Exécution du déploiement selon la cible
case $TARGET in
    fargate)
        deploy_fargate
        APP_URL=$(cd "terraform/environments/$ENVIRONMENT" && terraform output -raw application_url)
        ;;
    lambda)
        deploy_lambda
        APP_URL=$(cd "terraform/environments/$ENVIRONMENT-lambda" && terraform output -raw application_url)
        ;;
    *)
        echo "❌ Cible non supportée: $TARGET"
        exit 1
        ;;
esac

# Tests de fumée
if run_smoke_tests "$APP_URL"; then
    echo "🎉 Déploiement et tests terminés avec succès!"
    echo "📝 Résumé:"
    echo "   - Environnement: $ENVIRONMENT"
    echo "   - Cible: $TARGET"
    echo "   - URL: $APP_URL"
    echo "   - Région: $AWS_REGION"
else
    echo "❌ Les tests de fumée ont échoué"
    exit 1
fi

