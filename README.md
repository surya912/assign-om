# Idea Board - AI-First, Cloud-Agnostic DevOps Platform

## Overview

This project demonstrates a modern, AI-enhanced DevOps platform for deploying a full-stack application across multiple cloud providers. The Idea Board application is a simple full-stack app that allows users to submit and view ideas, deployed using cloud-agnostic infrastructure and an AI-powered CI/CD pipeline.

## Architecture

### High-Level Architecture

```
┌─────────────────┐
│   React App     │  (Frontend - Port 3000)
│   (Frontend)    │
└────────┬────────┘
         │ HTTP
         ▼
┌─────────────────┐
│   FastAPI       │  (Backend - Port 8000)
│   (Backend)     │
└────────┬────────┘
         │ SQL
         ▼
┌─────────────────┐
│   PostgreSQL    │  (Database - Port 5432)
│   (Database)    │
└─────────────────┘
```

### Cloud Infrastructure

The infrastructure is designed to be cloud-agnostic and supports:
- **AWS**: EKS (Kubernetes) + RDS (PostgreSQL)
- **GCP**: GKE (Kubernetes) + Cloud SQL (PostgreSQL)
- **Azure**: AKS (Kubernetes) + Azure Database for PostgreSQL (extensible)

### AI-Powered CI/CD Pipeline

The CI/CD pipeline includes several AI-enhanced features:

1. **AI-Assisted Command Generation**: Uses OpenAI/Anthropic to generate deployment commands from natural language
2. **Dynamic Environment Configuration**: AI suggests optimal infrastructure configurations based on environment type
3. **Intelligent Health Checks**: AI analyzes logs and metrics to detect deployment issues and trigger rollbacks
4. **Generative IaC**: AI can generate/modify Terraform configurations based on specifications

## Project Structure

```
idea-board/
├── frontend/              # React application
├── backend/               # FastAPI application
├── infrastructure/        # Terraform IaC
│   ├── terraform/
│   │   ├── modules/       # Reusable modules
│   │   └── providers/     # Cloud-specific configs
│   └── scripts/           # Deployment scripts
├── .github/workflows/     # CI/CD pipelines
└── README.md
```

## Prerequisites

- Docker and Docker Compose
- Node.js 18+ (for local frontend development)
- Python 3.11+ (for local backend development)
- Terraform 1.5+
- kubectl
- Cloud provider CLI tools (AWS CLI, gcloud, or Azure CLI)
- OpenAI API key or Anthropic API key (for AI features)

## Local Development

### Step 1: Clone the Repository

```bash
git clone <your-repo-url>
cd idea-board
```

### Step 2: Run with Docker Compose

The easiest way to run the entire stack locally:

```bash
docker-compose up --build
```

This will:
- Build and start the PostgreSQL database
- Build and start the FastAPI backend
- Build and start the React frontend

The application will be available at:
- Frontend: http://localhost:3000
- Backend API: http://localhost:8000
- API Docs: http://localhost:8000/docs

### Step 3: Verify the Application

1. Open http://localhost:3000 in your browser
2. Submit a new idea using the form
3. View all ideas in the list

### Manual Setup (Alternative)

If you prefer to run components separately:

#### Backend

```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

#### Frontend

```bash
cd frontend
npm install
npm start
```

#### Database

```bash
docker run -d \
  --name postgres \
  -e POSTGRES_USER=ideaboard \
  -e POSTGRES_PASSWORD=ideaboard \
  -e POSTGRES_DB=ideaboard \
  -p 5432:5432 \
  postgres:15
```

## Cloud Deployment

### Configuration

1. Set up cloud provider credentials:
   - **AWS**: Configure AWS CLI or set `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`
   - **GCP**: Run `gcloud auth login` and `gcloud auth application-default login`
   - **Azure**: Run `az login`

2. Set environment variables for AI features:
   ```bash
   export OPENAI_API_KEY="your-key-here"
   # OR
   export ANTHROPIC_API_KEY="your-key-here"
   ```

3. Configure Terraform variables:
   ```bash
   cd infrastructure/terraform/providers/aws  # or gcp
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

### Deploy to AWS

```bash
cd infrastructure/terraform/providers/aws
terraform init
terraform plan
terraform apply
```

### Deploy to GCP

```bash
cd infrastructure/terraform/providers/gcp
terraform init
terraform plan
terraform apply
```

### Post-Deployment

After deployment, Terraform will output:
- Kubernetes cluster endpoint
- Database connection details
- Application URLs

Use the provided scripts to deploy the application:

```bash
cd infrastructure/scripts
./deploy.sh <cloud-provider> <environment>
```

## AI Integration Details

### 1. AI-Assisted Command Generation

The pipeline can generate deployment commands from natural language. For example:

- PR comment: `/deploy-preview feature-x`
- Pipeline triggers AI to generate:
  ```bash
  kubectl create namespace preview-feature-x
  kubectl apply -f k8s/preview/ -n preview-feature-x
  ```

**Implementation**: Uses OpenAI GPT-4 or Claude to parse intent and generate appropriate kubectl/terraform commands.

### 2. Dynamic Environment Configuration

AI suggests infrastructure configurations based on environment type:

- Input: "cost-sensitive staging"
- AI Output: Smaller instance types, fewer replicas, basic monitoring

- Input: "high-availability production"
- AI Output: Multi-AZ deployment, auto-scaling, comprehensive monitoring

**Implementation**: AI analyzes requirements and generates Terraform variable files.

### 3. Intelligent Health Checks & Rollbacks

After deployment, AI analyzes:
- Application logs for errors
- Metrics (CPU, memory, request rates)
- Response times

If anomalies detected:
1. Automatic rollback triggered
2. AI generates human-readable summary
3. Notification sent to team

**Implementation**: Uses AI to parse logs and metrics, detect patterns indicating issues.

### 4. Generative IaC

AI can generate Terraform modules for new services:

- Input: Simple YAML specification
- Output: Complete Terraform module with best practices

**Implementation**: AI generates Terraform code following project patterns and cloud best practices.

## Cloud-Agnostic Approach

### Design Principles

1. **Abstraction Layer**: All cloud-specific resources are abstracted into reusable Terraform modules
2. **Provider Abstraction**: Common interface for Kubernetes and database across providers
3. **Configuration-Driven**: Environment-specific configs stored separately from code
4. **Unified Pipeline**: Single CI/CD pipeline works across all cloud providers

### Module Structure

```
modules/
├── kubernetes/     # K8s cluster (EKS/GKE/AKS)
├── postgresql/     # Database (RDS/Cloud SQL/Azure DB)
└── networking/     # VPC, subnets, security groups
```

### Adding a New Cloud Provider

1. Create provider directory: `infrastructure/terraform/providers/<new-provider>`
2. Implement provider-specific modules (following existing patterns)
3. Update CI/CD pipeline to support new provider
4. Test deployment

## CI/CD Pipeline

The GitHub Actions workflow (`.github/workflows/deploy.yml`) includes:

1. **Build & Test**: Build Docker images, run tests
2. **AI Analysis**: AI reviews code changes and suggests improvements
3. **Infrastructure Planning**: AI-assisted Terraform planning
4. **Deploy**: Deploy to target cloud provider
5. **Health Check**: AI-powered post-deployment validation
6. **Rollback**: Automatic rollback if health check fails

### Triggering Deployments

- **Push to main**: Deploy to production
- **PR with `/deploy-preview`**: Deploy preview environment
- **Manual workflow dispatch**: Deploy to specified environment

## Monitoring & Observability

- Application logs: Centralized logging (CloudWatch/Stackdriver)
- Metrics: Prometheus + Grafana
- Alerts: AI-powered anomaly detection

## Security

- Secrets managed via cloud provider secret managers
- Network policies for Kubernetes
- Database encryption at rest and in transit
- Regular security scanning in CI/CD pipeline

## Troubleshooting

### Local Development Issues

- **Port conflicts**: Change ports in `docker-compose.yml`
- **Database connection**: Check `DATABASE_URL` in backend `.env`
- **CORS errors**: Verify backend CORS settings

### Deployment Issues

- **Terraform errors**: Check cloud provider credentials
- **Kubernetes issues**: Verify `kubectl` context
- **AI features not working**: Check API key configuration

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

MIT License

## Contact

For questions or issues, please open an issue in the repository.

