# VPC Name Discovery Example

This example demonstrates how to deploy an EKS cluster by discovering a VPC using its Name tag.

## What This Example Does

- **VPC Discovery by Name**: Finds VPC by looking for the `Name` tag
- **Automatic Subnet Selection**: Uses private subnets with `kubernetes.io/role/internal-elb = "1"`
- **Custom Node Configuration**: Shows how to override default node group settings
- **Production Ready**: Includes larger instance types and scaling configuration

## Prerequisites

1. AWS CLI configured with appropriate permissions
2. A VPC with the specified name tag (update `vpc_name` in `main.tf`)
3. Private subnets in the VPC tagged with `kubernetes.io/role/internal-elb = "1"`
4. Terraform >= 1.0

## Usage

1. Update the `vpc_name` variable in `main.tf` to match your VPC's Name tag
2. Optionally customize the node group settings
3. Deploy:

```bash
terraform init
terraform plan
terraform apply
```

## Configuration Details

| Setting | Value |
|---------|--------|
| VPC Discovery | By Name tag |
| Subnet Discovery | Automatic (tagged subnets) |
| Instance Type | t3.large |
| Node Count | 3 (desired), 2 (min), 6 (max) |
| Scaling | Enhanced for production workloads |