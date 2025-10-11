#!/bin/bash

# Validate All Examples Script
set -e

echo "🔍 Validating all EKS examples..."

EXAMPLES_DIR="examples"
EXAMPLES=("fargate" "flux-cd" "on-demand" "spot")

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
    else
        echo -e "${RED}❌ $2${NC}"
    fi
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Check if we're in the right directory
if [ ! -d "$EXAMPLES_DIR" ]; then
    echo "❌ Examples directory not found. Run this script from the repository root."
    exit 1
fi

# Validate each example
for example in "${EXAMPLES[@]}"; do
    echo "=================================================="
    echo "🔍 Validating example: $example"
    echo "=================================================="
    
    EXAMPLE_PATH="$EXAMPLES_DIR/$example"
    
    if [ ! -d "$EXAMPLE_PATH" ]; then
        print_status 1 "Example directory $example not found"
        continue
    fi
    
    cd "$EXAMPLE_PATH"
    
    # Check required files
    echo "📋 Checking required files..."
    
    required_files=("main.tf" "variables.tf" "outputs.tf" "versions.tf" "README.md")
    for file in "${required_files[@]}"; do
        if [ -f "$file" ]; then
            print_status 0 "$file exists"
        else
            print_status 1 "$file missing"
        fi
    done
    
    # Check if terraform.tfvars exists
    if [ -f "terraform.tfvars" ]; then
        print_status 0 "terraform.tfvars exists"
    else
        print_warning "terraform.tfvars missing - copy from terraform.tfvars.example"
    fi
    
    # Terraform validation
    echo -e "\n🔧 Running Terraform validation..."
    
    # Initialize if needed
    if [ ! -d ".terraform" ]; then
        echo "Initializing Terraform..."
        terraform init -backend=false >/dev/null 2>&1
    fi
    
    # Validate
    if terraform validate >/dev/null 2>&1; then
        print_status 0 "Terraform validation passed"
    else
        print_status 1 "Terraform validation failed"
        terraform validate
    fi
    
    # Format check
    if terraform fmt -check >/dev/null 2>&1; then
        print_status 0 "Terraform formatting is correct"
    else
        print_warning "Terraform files need formatting (run: terraform fmt)"
    fi
    
    # Check for common configuration issues
    echo -e "\n🔍 Checking configuration..."
    
    # Check if enable_helm_deployments is properly configured in flux-cd example
    if [ "$example" = "flux-cd" ]; then
        if grep -q "enable_helm_deployments.*=.*true" main.tf; then
            print_status 0 "Helm deployments enabled in Flux CD example"
        else
            print_warning "Helm deployments should be enabled in Flux CD example"
        fi
        
        if grep -q "enable_load_balancer_controller.*=.*true" main.tf; then
            print_status 0 "Load Balancer Controller enabled"
        else
            print_warning "Load Balancer Controller should be enabled"
        fi
        
        if grep -q "enable_external_dns.*=.*true" main.tf; then
            print_status 0 "ExternalDNS enabled"
        else
            print_warning "ExternalDNS should be enabled"
        fi
    fi
    
    # Check module source path
    if grep -q 'source.*=.*"../../modules/eks"' main.tf; then
        print_status 0 "Module source path is correct"
    else
        print_warning "Module source path may be incorrect"
    fi
    
    # Check variable defaults
    if [ -f "variables.tf" ]; then
        if grep -q "default.*=" variables.tf; then
            print_status 0 "Variables have default values"
        else
            print_warning "Consider adding default values to variables"
        fi
    fi
    
    echo -e "\n✅ Validation for $example completed"
    echo ""
    
    cd - >/dev/null
done

echo "=================================================="
echo "🎉 All examples validated!"
echo "=================================================="

echo -e "\n📋 Summary of checks performed:"
echo "- File structure validation"
echo "- Terraform syntax validation"
echo "- Terraform formatting check"
echo "- Module source path verification"
echo "- Configuration best practices"

echo -e "\n🚀 To test an example:"
echo "1. cd examples/<example-name>"
echo "2. cp terraform.tfvars.example terraform.tfvars"
echo "3. Edit terraform.tfvars with your values"
echo "4. terraform init"
echo "5. terraform plan"
echo "6. terraform apply"

echo -e "\n💡 For the Flux CD example, ensure:"
echo "- enable_helm_deployments = true (for Load Balancer Controller & ExternalDNS)"
echo "- enable_load_balancer_controller = true"
echo "- enable_external_dns = true"
echo "- Valid Git repository URL configured"