# Deployment Guide

This guide provides instructions for deploying the Zero Trust Payment Processing solution to Google Cloud Platform.

## Infrastructure Setup

### Prerequisites

- Google Cloud Platform account with billing enabled
- Terraform 1.5+
- Google Cloud SDK
- Required IAM permissions:
  - Project Owner or Editor
  - Security Admin
  - Network Admin

### Initial Setup

1. Create a GCP project:
   ```bash
   gcloud projects create zero-trust-payment-dev
   gcloud config set project zero-trust-payment-dev
   ```

2. Enable required APIs:
   ```bash
   gcloud services enable compute.googleapis.com \
     cloudbuild.googleapis.com \
     cloudkms.googleapis.com \
     cloudresourcemanager.googleapis.com \
     container.googleapis.com \
     containerregistry.googleapis.com \
     iam.googleapis.com \
     secretmanager.googleapis.com \
     servicenetworking.googleapis.com \
     sqladmin.googleapis.com \
     run.googleapis.com \
     vpcaccess.googleapis.com \
     apigee.googleapis.com \
     pubsub.googleapis.com
   ```

3. Create a service account for Terraform:
   ```bash
   gcloud iam service-accounts create terraform-sa \
     --display-name "Terraform Service Account"
   
   gcloud projects add-iam-policy-binding zero-trust-payment-dev \
     --member="serviceAccount:terraform-sa@zero-trust-payment-dev.iam.gserviceaccount.com" \
     --role="roles/owner"
   
   gcloud iam service-accounts keys create terraform-sa-key.json \
     --iam-account=terraform-sa@zero-trust-payment-dev.iam.gserviceaccount.com
   ```

4. Create a GCS bucket for Terraform state:
   ```bash
   gsutil mb -l us-central1 gs://zero-trust-payment-terraform-state
   gsutil versioning set on gs://zero-trust-payment-terraform-state
   ```

## Terraform Deployment

### Development Environment

1. Navigate to the development environment directory:
   ```bash
   cd infrastructure/environments/dev
   ```

2. Create a `terraform.tfvars` file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your project details
   ```

3. Initialize Terraform:
   ```bash
   terraform init
   ```

4. Plan the deployment:
   ```bash
   terraform plan -out=tfplan
   ```

5. Apply the configuration:
   ```bash
   terraform apply tfplan
   ```

### Production Environment

1. Create a separate GCP project for production:
   ```bash
   gcloud projects create zero-trust-payment-prod
   ```

2. Repeat the API enablement and service account setup for the production project.

3. Navigate to the production environment directory:
   ```bash
   cd infrastructure/environments/prod
   ```

4. Create a `terraform.tfvars` file with production-specific values.

5. Deploy using Terraform:
   ```bash
   terraform init
   terraform plan -out=tfplan
   terraform apply tfplan
   ```

## CI/CD Setup

### GitHub Actions Configuration

1. Add the following secrets to your GitHub repository:
   - `GCP_PROJECT_ID`: Development project ID
   - `GCP_PROD_PROJECT_ID`: Production project ID
   - `GCP_PROJECT_NUMBER`: Development project number
   - `GCP_PROD_PROJECT_NUMBER`: Production project number
   - `GCP_SA_KEY`: Base64-encoded service account key
   - `SONAR_TOKEN`: SonarQube token
   - `ACCESS_POLICY_ID`: Access Context Manager policy ID
   - `ALLOWED_IP_RANGES`: JSON array of allowed IP ranges

2. The CI/CD pipeline will automatically build, test, and deploy changes:
   - Pushes to feature branches: Build and test only
   - Merges to `develop`: Deploy to development environment
   - Merges to `main`: Deploy to production environment

## Manual Deployment

If you need to deploy manually:

1. Build the Docker images:
   ```bash
   ./gradlew jib
   ```

2. Deploy to Cloud Run:
   ```bash
   gcloud run deploy user-management \
     --image gcr.io/zero-trust-payment-dev/user-management:latest \
     --platform managed \
     --region us-central1 \
     --service-account user-management-sa@zero-trust-payment-dev.iam.gserviceaccount.com \
     --vpc-connector serverless-vpc-connector \
     --ingress internal
   ```

3. Repeat for each microservice.

## Post-Deployment Verification

1. Check service health:
   ```bash
   gcloud run services describe user-management --region us-central1
   ```

2. Verify database connectivity:
   ```bash
   gcloud sql instances describe zero-trust-payment-dev-db
   ```

3. Test API endpoints through Apigee:
   ```bash
   curl -H "Authorization: Bearer $TOKEN" https://api.dev.payment-api.example.com/users
   ```

## Rollback Procedure

If you need to roll back a deployment:

1. Identify the previous working version:
   ```bash
   gcloud container images list-tags gcr.io/zero-trust-payment-dev/user-management
   ```

2. Deploy the previous version:
   ```bash
   gcloud run services update user-management \
     --image gcr.io/zero-trust-payment-dev/user-management:previous-tag \
     --region us-central1
   ```

## Monitoring

After deployment, monitor the services using:

1. Cloud Monitoring dashboards
2. Cloud Logging for application logs
3. Cloud Trace for request tracing
4. Security Command Center for security monitoring