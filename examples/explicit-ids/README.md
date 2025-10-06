# Explicit IDs Example

This example demonstrates how to deploy an EKS cluster using explicit VPC and subnet IDs when you know exactly which resources to use.

## What This Example Does

- **Explicit Resource Selection**: Uses specific VPC and subnet IDs (no discovery needed)
- **Private Cluster Configuration**: Shows how to configure a private-only cluster
- **SPOT Instance Usage**: Demonstrates cost optimization with SPOT instances
- **Multiple Instance Types**: Uses multiple instance types for better availability
- **Advanced Security**: Private endpoints with restricted CIDR access

## Prerequisites

1. AWS CLI configured with appropriate permissions
2. Known VPC ID and subnet IDs
3. Subnets should be in different AZs for high availability
4. Terraform >= 1.0

## Usage

1. Update the resource IDs in `main.tf`:
   - Replace `vpc_id` with your actual VPC ID
   - Replace `subnet_ids` with your actual subnet IDs
2. Optionally customize other settings
3. Deploy:

```bash
terraform init
terraform plan
terraform apply
```

## When to Use This Approach

- **Existing Infrastructure**: When you have well-defined, existing VPC and subnets
- **Strict Requirements**: When you need precise control over resource selection
- **CI/CD Pipelines**: When resource IDs are provided by other automation
- **Multi-Environment**: When different environments use different resource naming conventions

## Configuration Highlights

| Setting | Value |
|---------|--------|
| VPC Selection | Explicit ID |
| Subnet Selection | Explicit IDs |
| Cluster Access | Private only |
| Instance Strategy | SPOT instances for cost optimization |
| Node Count | 6 (desired), 3 (min), 12 (max) |
| Instance Types | m5.xlarge, m5a.xlarge |

## Security Considerations

This example configures a private cluster with:
- Private API endpoint enabled
- Public API endpoint disabled
- Restricted CIDR access to private networks only
- IRSA enabled for secure pod-to-AWS communication

## Cost Optimization

The configuration uses SPOT instances which can provide up to 90% cost savings compared to On-Demand instances, perfect for development and non-critical workloads.