# Configuring Storage

## To setup an S3 bucket and an IAM role and policy:

```bash
cd infrastructure/loki
# Initialize Terraform
terraform init
```

export AWS_PROFILE=<profile in ~/.aws/config>
export AWS_REGION=<region of EKS cluster>

Save the OIDC provider in an environment variable:

```bash
oidc_provider=$(aws eks describe-cluster --name <EKS cluster> --query "cluster.identity.oidc.issuer" --output text | sed -e "s/^https:\/\///")
```

See the IAM OIDC provider guide for a guide for creating a provider.

Apply the Terraform module 
```bash
terraform apply -var region="$AWS_REGION" -var cluster_name=<EKS cluster>"
```
Note, the bucket name defaults to loki-data but can be changed via the bucket_name variable.