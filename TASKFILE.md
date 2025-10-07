# AWS EKS Module Task Runner

This Taskfile provides a standardized way to test, validate, and manage the AWS EKS### Maintenance Tasks

```bash
# Initialize all modules and examples
task init-all

# Clean all state files and caches
task clean

# Format all files
task format

# Run security scan
task security-scan

# Estimate costs
task cost-estimate
```and its examples.

## Prerequisites

### Required Tools

1. **Task Runner**: Install [Task](https://taskfile.dev/)
   ```bash
   # macOS
   brew install go-task/tap/go-task
   
   # Linux/Windows - see https://taskfile.dev/installation/
   ```

2. **Terraform**: Version >= 1.0
   ```bash
   # macOS
   brew install terraform
   ```

3. **AWS CLI**: Configured with appropriate permissions
   ```bash
   aws configure
   ```

### Optional Tools (for advanced features)

- **terraform-docs**: For documentation generation
  ```bash
  brew install terraform-docs
  ```

- **tfsec**: For security scanning
  ```bash
  brew install tfsec
  ```

- **infracost**: For cost estimation
  ```bash
  # See https://www.infracost.io/docs/#quick-start
  ```

## Quick Start

1. **View all available tasks**:
   ```bash
   task --list
   ```

2. **Get detailed help**:
   ```bash
   task help
   ```

3. **Run complete test suite**:
   ```bash
   task test-all
   ```

## Repository Structure

This repository uses a centralized module structure:

```
aws-eks-module/
├── modules/eks/          # 🎯 Main EKS module (centralized)
├── examples/             # 📚 Complete usage examples
│   ├── simple-cluster/   # Minimal configuration
│   ├── vpc-name-discovery/  # VPC discovery by name
│   ├── tag-based-discovery/ # Discovery by custom tags
│   └── explicit-ids/     # Explicit resource IDs
├── main.tf              # 🚀 Root-level usage example
└── Taskfile.yml         # Task automation
```

## Common Workflows

### Development Workflow

```bash
# Format all Terraform files
task format

# Validate the main module
task validate

# Validate all examples
task validate-examples

# Plan all examples (syntax check)
task plan-examples
```

### Testing Individual Examples

```bash
# Validate specific example
task validate-simple-cluster

# Plan specific example (requires configured variables)
task plan-simple-cluster

# Apply specific example
task apply-simple-cluster

# Destroy specific example
task destroy-simple-cluster
```

### Before Deploying Examples

1. **Copy and customize variables**:
   ```bash
   cp examples/simple-cluster/terraform.tfvars.example examples/simple-cluster/terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

2. **Initialize and plan**:
   ```bash
   task plan-simple-cluster
   ```

3. **Apply when ready**:
   ```bash
   task apply-simple-cluster
   ```

### Maintenance Tasks

```bash
# Initialize all modules
task init-all

# Clean all state files and caches
task clean

# Format all files
task format

# Run security scan
task security-scan

# Estimate costs
task cost-estimate
```

## Available Examples

| Example | Description | Task Commands |
|---------|-------------|---------------|
| **simple-cluster** | Minimal configuration using module defaults | `task validate-simple-cluster`<br>`task plan-simple-cluster`<br>`task apply-simple-cluster` |
| **vpc-name-discovery** | VPC discovery by name tag | `task validate-vpc-name-discovery`<br>`task plan-vpc-name-discovery`<br>`task apply-vpc-name-discovery` |
| **tag-based-discovery** | VPC and subnet discovery by custom tags | `task validate-tag-based-discovery`<br>`task plan-tag-based-discovery`<br>`task apply-tag-based-discovery` |
| **explicit-ids** | Explicit VPC and subnet IDs (backward compatibility) | `task validate-explicit-ids`<br>`task plan-explicit-ids`<br>`task apply-explicit-ids` |

## Configuration

Each example includes a `terraform.tfvars.example` file. Copy this to `terraform.tfvars` and customize:

```bash
# Example for simple-cluster
cp examples/simple-cluster/terraform.tfvars.example examples/simple-cluster/terraform.tfvars
# Edit the values in terraform.tfvars
```

### Important Variables to Set

- `cluster_name`: Unique name for your EKS cluster
- `public_access_cidrs`: Your IP address for API server access (security)
- `vpc_name` or `vpc_tags` or `vpc_id`: Depending on the example
- `subnet_tags` or `subnet_ids`: Depending on the example

## Safety Features

- All plan operations create plan files for review
- Apply and destroy operations require explicit task calls
- Variables are isolated per example
- AWS credentials validation before operations

## Troubleshooting

### Common Issues

1. **Task not found**:
   ```bash
   brew install go-task/tap/go-task
   ```

2. **AWS credentials not configured**:
   ```bash
   aws configure
   # or
   export AWS_PROFILE=your-profile
   ```

3. **Terraform not initialized**:
   ```bash
   task init-all
   ```

4. **Plan fails with variable errors**:
   - Copy and customize `terraform.tfvars.example` to `terraform.tfvars`
   - Ensure all required variables are set

### Getting Help

- Run `task help` for detailed workflow guidance
- Check individual example READMEs in `examples/*/README.md`
- Review the main module documentation in `modules/eks/`
- Review the main repository README in the repository root

## CI/CD Integration

This Taskfile is designed to work in CI/CD pipelines:

```yaml
# Example GitHub Actions usage
- name: Run Terraform Tests
  run: |
    task test-all
    task plan-examples
```

## Advanced Usage

### Custom Variables

Pass additional arguments to Terraform commands:

```bash
# Apply with auto-approve
task apply-simple-cluster -- -auto-approve

# Plan with specific var
task plan-simple-cluster -- -var="cluster_name=my-custom-name"

# Destroy with auto-approve
task destroy-simple-cluster -- -auto-approve
```

### Parallel Execution

Task supports parallel execution for independent operations:

```bash
# This will run validations in parallel
task validate-examples
```

### Working with the Centralized Module

The main EKS module is located in `modules/eks/`. When working on the module itself:

```bash
# Validate the main module
cd modules/eks
terraform validate

# Format the main module
cd modules/eks
terraform fmt

# Or use tasks from the root
task validate  # validates modules/eks/
task format    # formats all files including modules/eks/
```

## Security Best Practices

1. **Always restrict API access**: Set `public_access_cidrs` to your IP
2. **Review plans**: Always review Terraform plans before applying
3. **Use least privilege**: Configure AWS credentials with minimum required permissions
4. **Clean up**: Use destroy tasks to clean up test resources
5. **Scan for security issues**: Use `task security-scan` regularly

## Module Development

When developing the centralized module (`modules/eks/`):

1. **Make changes in `modules/eks/`**: All module logic is centralized here
2. **Test with examples**: Use the examples to test your module changes
3. **Update documentation**: Keep module outputs and variables documented
4. **Validate thoroughly**: Run `task test-all` before committing changes

## Example Development

When creating new examples:

1. **Reference the centralized module**: Always use `source = "../../modules/eks"`
2. **Include complete configuration**: Examples should be deployable independently
3. **Add comprehensive README**: Document the specific use case and configuration
4. **Test thoroughly**: Validate and plan before adding to repository

---

For more information, see the main [README.md](README.md) and [Copilot Instructions](.github/copilot-instructions.md).