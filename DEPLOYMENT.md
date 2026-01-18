# Deployment Guide

This guide provides detailed instructions for deploying the Idea Board application to various cloud providers.

## Prerequisites

Before deploying, ensure you have:

1. **Cloud Provider Accounts**
   - AWS account with appropriate permissions
   - GCP project with billing enabled
   - (Optional) Azure subscription

2. **Local Tools**
   - Terraform >= 1.5.0
   - kubectl
   - Docker
   - Cloud provider CLIs (aws-cli, gcloud, az)

3. **API Keys**
   - OpenAI API key (for AI features) or Anthropic API key
   - GitHub Personal Access Token (for container registry)

## Step-by-Step Deployment

### 1. Configure Cloud Provider Credentials

#### AWS
```bash
aws configure
# Enter your AWS Access Key ID, Secret Access Key, and region
```

#### GCP
```bash
gcloud auth login
gcloud auth application-default login
gcloud config set project YOUR_PROJECT_ID
```

### 2. Configure Terraform Variables

#### For AWS:
```bash
cd infrastructure/terraform/providers/aws
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

#### For GCP:
```bash
cd infrastructure/terraform/providers/gcp
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

### 3. Initialize and Apply Terraform

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply infrastructure
terraform apply
```

This will create:
- VPC and networking components
- Kubernetes cluster (EKS/GKE/AKS)
- PostgreSQL database (RDS/Cloud SQL/Azure DB)

### 4. Configure kubectl

After Terraform completes, configure kubectl:

#### AWS:
```bash
aws eks update-kubeconfig --name idea-board-cluster --region us-east-1
```

#### GCP:
```bash
gcloud container clusters get-credentials idea-board-cluster --region us-central1
```

### 5. Create Database Secret

```bash
# Get database connection string from Terraform output
terraform output db_connection_string

# Create Kubernetes secret
kubectl create secret generic db-credentials \
  --from-literal=connection-string="<connection-string-from-output>"
```

### 6. Build and Push Docker Images

```bash
# Set your container registry
export REGISTRY=ghcr.io/YOUR_USERNAME

# Build and push backend
cd backend
docker build -t $REGISTRY/idea-board-backend:latest .
docker push $REGISTRY/idea-board-backend:latest

# Build and push frontend
cd ../frontend
docker build -t $REGISTRY/idea-board-frontend:latest .
docker push $REGISTRY/idea-board-frontend:latest
```

### 7. Update Kubernetes Manifests

Edit `k8s/backend-deployment.yaml` and `k8s/frontend-deployment.yaml` to use your image registry.

### 8. Deploy to Kubernetes

```bash
# Using the deployment script
cd infrastructure/scripts
./deploy.sh aws production

# Or manually
kubectl apply -f ../../k8s/
```

### 9. Verify Deployment

```bash
# Check pod status
kubectl get pods

# Check services
kubectl get services

# Get service URLs
kubectl get service frontend -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
kubectl get service backend -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

### 10. Run Health Check

```bash
cd infrastructure/scripts
export OPENAI_API_KEY="your-key-here"
./ai-health-check.sh idea-board-production
```

## Using CI/CD Pipeline

### GitHub Actions Setup

1. **Add Secrets to GitHub Repository:**
   - `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`
   - `GCP_SA_KEY` (Service Account JSON)
   - `GCP_PROJECT_ID`
   - `OPENAI_API_KEY` (for AI features)

2. **Push to Main Branch:**
   - The pipeline will automatically:
     - Build Docker images
     - Run tests
     - Deploy to production

3. **Manual Deployment:**
   - Go to Actions tab
   - Select "AI-Powered CI/CD Pipeline"
   - Click "Run workflow"
   - Select cloud provider and environment

4. **Preview Deployments:**
   - Comment on a PR: `/deploy-preview feature-name`
   - The AI will generate deployment commands
   - A preview environment will be created

## Troubleshooting

### Terraform Issues

**Error: Authentication failed**
- Verify cloud provider credentials are configured correctly
- Check IAM permissions

**Error: Resource already exists**
- Check if resources were created manually
- Import existing resources or destroy and recreate

### Kubernetes Issues

**Pods not starting**
- Check pod logs: `kubectl logs <pod-name>`
- Verify secrets are created: `kubectl get secrets`
- Check resource limits

**Services not accessible**
- Verify LoadBalancer is provisioned (may take a few minutes)
- Check security groups/firewall rules
- Verify service selector matches pod labels

### Database Connection Issues

- Verify database security group allows connections from Kubernetes nodes
- Check database endpoint from Terraform output
- Verify connection string in Kubernetes secret

## Multi-Cloud Deployment

To deploy to multiple cloud providers:

1. Deploy to AWS (follow steps above)
2. Deploy to GCP:
   ```bash
   cd infrastructure/terraform/providers/gcp
   terraform init
   terraform apply
   ```
3. Update DNS/load balancer to route traffic between providers

## Cost Optimization

- Use smaller instance types for staging
- Enable auto-scaling
- Use spot instances for non-production
- Schedule database backups appropriately
- Monitor and set up billing alerts

## Security Best Practices

- Use secrets management (AWS Secrets Manager, GCP Secret Manager)
- Enable database encryption
- Use private subnets for databases
- Implement network policies
- Regular security scanning
- Rotate credentials regularly

## Monitoring

Set up monitoring for:
- Application metrics (Prometheus)
- Logs (CloudWatch/Stackdriver)
- Alerts (PagerDuty, Slack)
- Cost tracking

## Rollback Procedure

If deployment fails:

```bash
# Rollback Kubernetes deployments
kubectl rollout undo deployment/backend
kubectl rollout undo deployment/frontend

# Or destroy infrastructure
terraform destroy
```

