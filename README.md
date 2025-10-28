# GitOps Armada Demo Repository

## Overview

This repository demonstrates the **GitOps Armada** framework presented at ArgoCon North America 2025 - a GitOps-first pipeline for automating Kubernetes fleet management across multiple clouds.

## What This Demo Shows

- **GitOps-first pipeline** for cluster lifecycle management
- **Automatic cluster onboarding** into Argo CD
- **Attribute-based app placement** by cloud provider, region, and environment
- **Declarative, traceable, and repeatable** deployments
- **DR-ready** infrastructure to recover workloads across clusters

## Architecture

The GitOps Armada uses four core components:

1. **Terraform/OpenTofu** - Infrastructure and cluster provisioning
2. **Secret Manager** (AWS Secrets Manager) - Stores cluster metadata
3. **External Secrets Operator** - Pulls cluster identity/secrets into Argo CD fleet
4. **Argo CD ApplicationSets** - Deploy infrastructure/workloads per cluster attributes

## How It Works

1. Terraform creates new cluster(s)
2. Writes metadata (name, region, provider, environment) into AWS Secrets Manager
3. ESO watches for new clusters and creates Argo CD cluster secrets with label `argocd.argoproj.io/secret-type=cluster`
4. Argo CD discovers clusters, then ApplicationSets match attributes and deploy applications

## Repository Structure

```
├── terraform/
│   ├── aws/          # EKS cluster provisioning
│   └── gcp/          # GKE cluster provisioning
├── apps/
│   ├── aws/          # AWS-specific applications
│   ├── gcp/          # GCP-specific applications
│   └── common/       # Universal applications
├── external-secrets/ # ExternalSecrets manifests
└── argocd/
    └── applicationsets/  # ApplicationSet definitions
```

## Prerequisites

- AWS account with permissions to create EKS clusters
- GCP account with permissions to create GKE clusters
- Argo CD installed in a management cluster
- AWS credentials configured for Terraform and External Secrets Operator

## Quick Start

### 1. Provision Infrastructure

**For EKS:**
```bash
cd terraform/aws
terraform init
terraform apply -var="cluster_name=eks-example" -var="environment=dev" -var="eks_admin_role_arn=<YOUR_ROLE_ARN>"
```

**For GKE:**
```bash
cd terraform/gcp
terraform init
terraform apply -var="cluster_name=gke-example" -var="environment=production" -var="project_id=<YOUR_PROJECT_ID>"
```

Terraform will:
- Create the Kubernetes cluster
- Store cluster metadata in AWS Secrets Manager

### 2. Configure External Secrets Operator

**⚠️ IMPORTANT NOTES:**

1. **External Secret manifests should be generated automatically** in production environments. This can be done through:
   - Terraform provisioners
   - CI/CD pipelines
   - GitOps automation tools

2. **Token authentication is used for demonstration purposes only.** In production, use:
   - AWS IAM Roles for Service Accounts (IRSA)
   - GCP Workload Identity
   - Kubernetes Service Account tokens with proper RBAC

**For demonstration, create AWS credentials secret:**
```bash
kubectl create secret generic aws-credentials -n argocd \
  --from-literal=access-key=<YOUR_ACCESS_KEY> \
  --from-literal=secret-access-key=<YOUR_SECRET_KEY>
```

**Apply the SecretStore:**
```bash
kubectl apply -f argocd/secretstore.yaml
```

**Generate and apply External Secret manifests** (in production, this should be automated):
```bash
# Example for EKS cluster
kubectl apply -f external-secrets/eks-secret.yaml

# Example for GKE cluster
kubectl apply -f external-secrets/gke-secret.yaml
```

### 3. Deploy ApplicationSets

```bash
kubectl apply -f argocd/applicationsets/
```

The ApplicationSets will automatically:
- Discover clusters via ESO labels
- Deploy AWS-specific apps to AWS clusters
- Deploy GCP-specific apps to GCP clusters
- Deploy common tools to all clusters

## Attribute-Based Deployment

Applications are deployed based on cluster attributes:

- **Cloud-specific**: AWS clusters get Karpenter and AWS Load Balancer Controller
- **Cloud-specific**: GCP clusters get GCP infrastructure apps
- **Universal**: All clusters get common tooling like ingress-nginx

## ApplicationSet Examples

### AWS Dev Clusters
Deploys AWS-specific infrastructure to clusters with:
- `cloud-provider: aws`
- `environment: dev`

### GCP Clusters
Deploys GCP-specific infrastructure to clusters with:
- `cloud-provider: gcp`

### Common Applications
Deploys universal tools to all managed clusters regardless of cloud provider or environment.

## Demo Applications

The repository includes sample applications:

- **AWS Load Balancer Controller** - Manages AWS ALBs/NLBs
- **Karpenter** - Just-in-time node provisioning for AWS
- **Ingress-NGINX** - Universal ingress controller
- **Guestbook** - Sample application for testing

## Cleanup

```bash
# Delete ApplicationSets
kubectl delete -f argocd/applicationsets/

# Destroy infrastructure
cd terraform/aws && terraform destroy
cd terraform/gpc && terraform destroy
```

## Contributing

This is a demonstration repository. For questions or improvements, please open an issue.

## Related Resources

- [ArgoCon North America 2025 Presentation](https://sched.co/28D96)
- [Argo CD Documentation](https://argo-cd.readthedocs.io/)
- [External Secrets Operator](https://external-secrets.io/)
