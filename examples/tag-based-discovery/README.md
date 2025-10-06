# Tag-Based Discovery Example

This example demonstrates how to discover VPC and subnets using custom tags instead of relying on names or explicit IDs.

## What This Example Does

- **VPC Discovery by Tags**: Finds VPC using multiple custom tags for precise matching
- **Subnet Discovery by Tags**: Uses custom tags to find appropriate subnets
- **Flexible Tagging**: Works with any tagging strategy your organization uses
- **Production Configuration**: Includes custom cluster version, enhanced logging, and larger node groups

## Prerequisites

1. AWS CLI configured with appropriate permissions
2. A VPC tagged with the specified tags (update `vpc_tags` in `main.tf`)
3. Subnets tagged with the specified tags (update `subnet_tags` in `main.tf`)
4. Terraform >= 1.0

## Usage

1. Update the tag values in `main.tf` to match your infrastructure:
   - `vpc_tags`: Tags that uniquely identify your VPC
   - `subnet_tags`: Tags that identify your target subnets
2. Optionally customize other settings
3. Deploy:

```bash
terraform init
terraform plan
terraform apply
```

## Tag Strategy Examples

### By Environment and Team
```hcl
vpc_tags = {
  Environment = "production"
  Team        = "platform"
}

subnet_tags = {
  Environment = "production"
  Type        = "private"
  Kubernetes  = "allowed"
}
```

### By Project and Tier
```hcl
vpc_tags = {
  Project = "ecommerce"
  Tier    = "production"
}

subnet_tags = {
  Project    = "ecommerce"
  Tier       = "production"
  SubnetType = "application"
}
```

## Configuration Details

| Setting | Value |
|---------|--------|
| VPC Discovery | Custom tags |
| Subnet Discovery | Custom tags |
| Kubernetes Version | 1.30 |
| Instance Type | m5.large |
| Node Count | 4 (desired), 2 (min), 8 (max) |
| Logging | All control plane logs enabled |