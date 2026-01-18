#!/bin/bash

# Deployment script for Idea Board application
# Usage: ./deploy.sh <cloud-provider> <environment>

set -e

CLOUD_PROVIDER=${1:-aws}
ENVIRONMENT=${2:-staging}

echo "🚀 Deploying Idea Board to $CLOUD_PROVIDER ($ENVIRONMENT)"

# Validate inputs
if [[ ! "$CLOUD_PROVIDER" =~ ^(aws|gcp|azure)$ ]]; then
    echo "❌ Invalid cloud provider: $CLOUD_PROVIDER"
    echo "Valid options: aws, gcp, azure"
    exit 1
fi

if [[ ! "$ENVIRONMENT" =~ ^(staging|production)$ ]]; then
    echo "❌ Invalid environment: $ENVIRONMENT"
    echo "Valid options: staging, production"
    exit 1
fi

# Set up cloud provider credentials
case $CLOUD_PROVIDER in
    aws)
        echo "📋 Configuring AWS credentials..."
        if ! command -v aws &> /dev/null; then
            echo "❌ AWS CLI not found. Please install it first."
            exit 1
        fi
        aws eks update-kubeconfig --name idea-board-cluster --region us-east-1 || {
            echo "❌ Failed to configure kubectl for AWS"
            exit 1
        }
        ;;
    gcp)
        echo "📋 Configuring GCP credentials..."
        if ! command -v gcloud &> /dev/null; then
            echo "❌ gcloud CLI not found. Please install it first."
            exit 1
        fi
        gcloud container clusters get-credentials idea-board-cluster --region us-central1 || {
            echo "❌ Failed to configure kubectl for GCP"
            exit 1
        }
        ;;
    azure)
        echo "📋 Configuring Azure credentials..."
        if ! command -v az &> /dev/null; then
            echo "❌ Azure CLI not found. Please install it first."
            exit 1
        fi
        az aks get-credentials --resource-group idea-board-rg --name idea-board-cluster || {
            echo "❌ Failed to configure kubectl for Azure"
            exit 1
        }
        ;;
esac

# Verify kubectl is configured
echo "✅ Verifying kubectl configuration..."
kubectl cluster-info || {
    echo "❌ kubectl not properly configured"
    exit 1
}

# Create namespace if it doesn't exist
NAMESPACE="idea-board-${ENVIRONMENT}"
echo "📦 Creating namespace: $NAMESPACE"
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

# Apply Kubernetes manifests
echo "📝 Applying Kubernetes manifests..."
kubectl apply -f ../../k8s/ -n "$NAMESPACE"

# Wait for deployments
echo "⏳ Waiting for deployments to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/backend -n "$NAMESPACE"
kubectl wait --for=condition=available --timeout=300s deployment/frontend -n "$NAMESPACE"

# Get service URLs
echo "🌐 Getting service URLs..."
BACKEND_URL=$(kubectl get service backend -n "$NAMESPACE" -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "Pending...")
FRONTEND_URL=$(kubectl get service frontend -n "$NAMESPACE" -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "Pending...")

echo ""
echo "✅ Deployment complete!"
echo "📊 Backend URL: http://${BACKEND_URL}"
echo "📊 Frontend URL: http://${FRONTEND_URL}"
echo ""
echo "To check status: kubectl get all -n $NAMESPACE"
echo "To view logs: kubectl logs -f deployment/backend -n $NAMESPACE"

