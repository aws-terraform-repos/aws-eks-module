#!/bin/bash
set -e

echo "🧪 EKS End-to-End Testing Script"
echo "=================================="

# Check if cluster is configured
echo "1. Checking kubectl configuration..."
if ! kubectl cluster-info &>/dev/null; then
    echo "❌ kubectl not configured. Run: aws eks update-kubeconfig --region us-east-1 --name test-eks-cluster"
    exit 1
fi
echo "✅ kubectl is configured"

# Check cluster info
echo -e "\n2. Cluster Information:"
kubectl cluster-info
echo ""
kubectl version --short

# Check nodes
echo -e "\n3. Checking nodes..."
kubectl get nodes -o wide

# Check system pods
echo -e "\n4. Checking system pods..."
kubectl get pods -n kube-system

# Check add-ons
echo -e "\n5. Checking EKS add-ons..."
aws eks describe-addon --cluster-name test-eks-cluster --addon-name vpc-cni --query 'addon.{Name:addonName,Version:addonVersion,Status:status}' --output table
aws eks describe-addon --cluster-name test-eks-cluster --addon-name coredns --query 'addon.{Name:addonName,Version:addonVersion,Status:status}' --output table
aws eks describe-addon --cluster-name test-eks-cluster --addon-name kube-proxy --query 'addon.{Name:addonName,Version:addonVersion,Status:status}' --output table
aws eks describe-addon --cluster-name test-eks-cluster --addon-name aws-ebs-csi-driver --query 'addon.{Name:addonName,Version:addonVersion,Status:status}' --output table

# Deploy test applications
echo -e "\n6. Deploying test applications..."
kubectl apply -f test-manifests/nginx-test.yaml
kubectl apply -f test-manifests/storage-test.yaml

# Wait for deployments
echo -e "\n7. Waiting for deployments to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/nginx-test -n test-app
kubectl wait --for=condition=available --timeout=300s deployment/storage-test -n test-app

# Check application status
echo -e "\n8. Checking application status..."
kubectl get pods -n test-app -o wide

# Test storage
echo -e "\n9. Testing persistent storage..."
kubectl get pvc -n test-app

# Test service discovery
echo -e "\n10. Testing service discovery..."
kubectl get services -n test-app

# Test IRSA (if configured)
echo -e "\n11. Checking IRSA configuration..."
kubectl get serviceaccounts -n kube-system | grep -E "(ebs-csi|vpc-cni)"

# Cleanup test
echo -e "\n12. Cleaning up test resources..."
read -p "Do you want to clean up test resources? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    kubectl delete namespace test-app
    echo "✅ Test resources cleaned up"
else
    echo "🔄 Test resources left running"
fi

echo -e "\n🎉 End-to-end testing completed successfully!"
echo "📊 Summary:"
echo "   - Cluster: test-eks-cluster"
echo "   - Kubernetes Version: $(kubectl version --short | grep Server | cut -d' ' -f3)"
echo "   - Nodes: $(kubectl get nodes --no-headers | wc -l)"
echo "   - Add-ons: vpc-cni, coredns, kube-proxy, aws-ebs-csi-driver"