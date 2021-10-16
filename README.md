![Halloween](./images/security_halloween.jpg)

# skeleton-keys
Using Boundary to access cryptically protected secrets

## What do we need for halloween?
- EKS cluster
- GitOPS
  - Argo (pipelines)
  - Terraform apply something
  - Checks for quality
- Boundary orchestrator (HA?)
  - Managed service accessible
- Boundary workers
- Vault cluster for integration

## Create CI user
Add a `secrets.tfvars` to the `setup` folder and add:
```terraform
github_repository = "<repository name>"
github_token      = "<github token with admin access on repository>"
aws_bucket        = "<bucket to be used for state management>"
```