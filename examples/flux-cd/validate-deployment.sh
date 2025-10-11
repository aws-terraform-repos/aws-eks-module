#!/bin/bash

# Flux CD EKS Deployment Validation Script
set -e

echo "🔍 Validating Flux CD EKS Deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to print status
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
    else
        echo -e "${RED}❌ $2${NC}"
        exit 1
    fi
}

# Function to print warning
print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Check prerequisites
echo "📋 Checking prerequisites..."
command_exists kubectl && print_status 0 "kubectl is installed" || print_status 1 "kubectl is required"
command_exists aws && print_status 0 "AWS CLI is installed" || print_status 1 "AWS CLI is required"

# Check cluster connectivity
echo -e "\n🔗 Checking cluster connectivity..."
kubectl cluster-info >/dev/null 2>&1 && print_status 0 "Cluster is accessible" || print_status 1 "Cannot connect to cluster"

# Get cluster name
CLUSTER_NAME=$(kubectl config current-context | cut -d/ -f2 2>/dev/null || echo "unknown")
echo "📍 Current cluster: $CLUSTER_NAME"

# Check nodes
echo -e "\n🖥️  Checking cluster nodes..."
NODE_COUNT=$(kubectl get nodes --no-headers 2>/dev/null | wc -l)
if [ "$NODE_COUNT" -gt 0 ]; then
    print_status 0 "Found $NODE_COUNT node(s)"
    kubectl get nodes
else
    print_status 1 "No nodes found"
fi

# Check kube-system pods
echo -e "\n🔧 Checking core system components..."
kubectl get pods -n kube-system >/dev/null 2>&1 && print_status 0 "kube-system namespace accessible" || print_status 1 "Cannot access kube-system"

# Check EKS add-ons
echo -e "\n📦 Checking EKS add-ons..."
addons=("coredns" "kube-proxy" "vpc-cni" "aws-ebs-csi-driver")
for addon in "${addons[@]}"; do
    if kubectl get deployment "$addon" -n kube-system >/dev/null 2>&1 || kubectl get daemonset "$addon" -n kube-system >/dev/null 2>&1; then
        print_status 0 "$addon is deployed"
    else
        print_warning "$addon not found"
    fi
done

# Check AWS Load Balancer Controller
echo -e "\n🚀 Checking AWS Load Balancer Controller..."
if kubectl get deployment aws-load-balancer-controller -n kube-system >/dev/null 2>&1; then
    print_status 0 "AWS Load Balancer Controller is deployed"
    LBC_READY=$(kubectl get deployment aws-load-balancer-controller -n kube-system -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
    if [ "$LBC_READY" = "2" ] || [ "$LBC_READY" = "1" ]; then
        print_status 0 "AWS Load Balancer Controller is ready"
    else
        print_warning "AWS Load Balancer Controller is not ready yet"
    fi
else
    print_warning "AWS Load Balancer Controller not found - Helm deployments may be disabled"
fi

# Check ExternalDNS
echo -e "\n🌐 Checking ExternalDNS..."
if kubectl get deployment external-dns -n kube-system >/dev/null 2>&1; then
    print_status 0 "ExternalDNS is deployed"
    EXTERNAL_DNS_READY=$(kubectl get deployment external-dns -n kube-system -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
    if [ "$EXTERNAL_DNS_READY" = "1" ]; then
        print_status 0 "ExternalDNS is ready"
    else
        print_warning "ExternalDNS is not ready yet"
    fi
else
    print_warning "ExternalDNS not found - Helm deployments may be disabled"
fi

# Check Flux CD
echo -e "\n🔄 Checking Flux CD..."
if kubectl get namespace flux-system >/dev/null 2>&1; then
    print_status 0 "flux-system namespace exists"
    
    # Check Flux CD controllers
    controllers=("source-controller" "kustomize-controller" "helm-controller" "notification-controller")
    for controller in "${controllers[@]}"; do
        if kubectl get deployment "$controller" -n flux-system >/dev/null 2>&1; then
            READY=$(kubectl get deployment "$controller" -n flux-system -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
            if [ "$READY" = "1" ]; then
                print_status 0 "$controller is ready"
            else
                print_warning "$controller is not ready yet"
            fi
        else
            print_warning "$controller not found"
        fi
    done
    
    # Check for image automation controllers (optional)
    if kubectl get deployment image-reflector-controller -n flux-system >/dev/null 2>&1; then
        print_status 0 "Image automation is enabled"
    else
        print_warning "Image automation controllers not found (may be disabled)"
    fi
    
else
    print_status 1 "flux-system namespace not found - Flux CD not installed"
fi

# Check GitRepository resources
echo -e "\n📚 Checking Flux CD GitRepository resources..."
GIT_REPOS=$(kubectl get gitrepositories -n flux-system --no-headers 2>/dev/null | wc -l)
if [ "$GIT_REPOS" -gt 0 ]; then
    print_status 0 "Found $GIT_REPOS GitRepository resource(s)"
    kubectl get gitrepositories -n flux-system
else
    print_warning "No GitRepository resources found"
fi

# Check Kustomization resources
echo -e "\n🔧 Checking Flux CD Kustomization resources..."
KUSTOMIZATIONS=$(kubectl get kustomizations -n flux-system --no-headers 2>/dev/null | wc -l)
if [ "$KUSTOMIZATIONS" -gt 0 ]; then
    print_status 0 "Found $KUSTOMIZATIONS Kustomization resource(s)"
    kubectl get kustomizations -n flux-system
else
    print_warning "No Kustomization resources found"
fi

# Check IRSA configuration
echo -e "\n🔐 Checking IRSA configuration..."
service_accounts=("aws-load-balancer-controller" "external-dns" "flux-cd")
for sa in "${service_accounts[@]}"; do
    namespace="kube-system"
    if [ "$sa" = "flux-cd" ]; then
        namespace="flux-system"
    fi
    
    if kubectl get serviceaccount "$sa" -n "$namespace" >/dev/null 2>&1; then
        ROLE_ARN=$(kubectl get serviceaccount "$sa" -n "$namespace" -o jsonpath='{.metadata.annotations.eks\.amazonaws\.com/role-arn}' 2>/dev/null)
        if [ -n "$ROLE_ARN" ]; then
            print_status 0 "$sa has IRSA role: $ROLE_ARN"
        else
            print_warning "$sa does not have IRSA annotation"
        fi
    else
        print_warning "$sa service account not found in $namespace"
    fi
done

# Check for common issues
echo -e "\n🔍 Checking for common issues..."

# Check if any pods are in error state
ERROR_PODS=$(kubectl get pods --all-namespaces --field-selector=status.phase=Failed --no-headers 2>/dev/null | wc -l)
if [ "$ERROR_PODS" -eq 0 ]; then
    print_status 0 "No failed pods found"
else
    print_warning "Found $ERROR_PODS failed pod(s)"
    kubectl get pods --all-namespaces --field-selector=status.phase=Failed
fi

# Check cluster events for errors
echo -e "\n📋 Recent cluster events..."
kubectl get events --all-namespaces --sort-by='.lastTimestamp' | tail -10

# Flux CLI check (if available)
echo -e "\n🔄 Flux CD status check..."
if command_exists flux; then
    flux check 2>/dev/null && print_status 0 "Flux CD system check passed" || print_warning "Flux CD system check failed"
else
    print_warning "Flux CLI not found - install with: curl -s https://fluxcd.io/install.sh | sudo bash"
fi

# Summary
echo -e "\n📊 Validation Summary:"
echo "=================================="
echo "Cluster: $CLUSTER_NAME"
echo "Nodes: $NODE_COUNT"
echo "GitRepositories: $GIT_REPOS"
echo "Kustomizations: $KUSTOMIZATIONS"
echo -e "\n✅ Validation completed!"

# Next steps
echo -e "\n🚀 Next Steps:"
echo "1. Check Terraform outputs: terraform output flux_cd_setup_instructions"
echo "2. Configure your Git repository for GitOps"
echo "3. Create authentication secrets if using private repositories"
echo "4. Monitor reconciliation: flux get kustomizations"
echo "5. Check logs if issues: kubectl logs -n flux-system -l app=source-controller"

if command_exists flux; then
    echo -e "\n💡 Useful Flux commands:"
    echo "  flux get sources git"
    echo "  flux get kustomizations"
    echo "  flux reconcile source git flux-system"
fi