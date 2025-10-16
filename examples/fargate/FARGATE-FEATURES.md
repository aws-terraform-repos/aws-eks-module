# AWS EKS Fargate Cluster Features

This Fargate example demonstrates a hybrid EKS cluster with both managed node groups and Fargate profiles for optimal cost and performance.

## Architecture Overview

The Fargate cluster uses a **hybrid compute model**:
- **Managed Node Group**: For system components requiring traditional nodes
- **Fargate Profiles**: For application workloads requiring serverless execution

## Implemented Features

### ✅ Node Groups (System Components)
- **System Node Group**: 1-3 t3.medium instances with `ON_DEMAND` pricing
- **Labels**: `role=system` for scheduling system components
- **Taints**: `CriticalAddonsOnly=true:NoSchedule` to prevent regular workloads
- **Purpose**: Runs AWS Load Balancer Controller, ExternalDNS, EBS CSI Driver

### ✅ Fargate Profiles (Application Workloads)

#### Default Profile
- **Namespace**: `default` with label `fargate=enabled`
- **Namespace**: `kube-system` with label `k8s-app=kube-dns`
- **Purpose**: Core DNS and default application pods

#### Applications Profile
- **Namespace**: `applications` (any pods)
- **Namespace**: `production` with label `compute-type=fargate`
- **Purpose**: Application workloads in dedicated namespaces

### ✅ DNS and Load Balancing
- **Route53 Integration**: Automatic hosted zone creation for `your-domain.com`
- **AWS Load Balancer Controller**: ALB/NLB support with IRSA
- **ExternalDNS**: Automatic DNS record management for ingresses/services

### ✅ Security Features
- **IRSA Support**: Secure AWS service access for pods
- **VPC Discovery**: Automatic VPC and subnet discovery using tags
- **Security Groups**: Properly configured for Fargate networking
- **API Access Control**: Configurable CIDR restrictions

### ✅ Storage and Networking
- **EBS CSI Driver**: Persistent volume support (runs on node group)
- **VPC CNI**: Enhanced networking with dedicated IRSA role
- **Subnet Configuration**: Uses private subnets with `kubernetes.io/role/internal-elb` tags

## Deployment Configuration

### Node Groups
```hcl
node_groups = {
  system = {
    desired_size   = 1
    max_size       = 3
    min_size       = 1
    instance_types = ["t3.medium"]
    capacity_type  = "ON_DEMAND"
    labels = {
      role = "system"
    }
    taints = [
      {
        key    = "CriticalAddonsOnly"
        value  = "true"
        effect = "NO_SCHEDULE"
      }
    ]
  }
}
```

### Fargate Profiles
```hcl
fargate_profiles = {
  default = {
    selectors = [
      {
        namespace = "default"
        labels = {
          fargate = "enabled"
        }
      },
      {
        namespace = "kube-system"
        labels = {
          k8s-app = "kube-dns"
        }
      }
    ]
  }
  
  applications = {
    selectors = [
      {
        namespace = "applications"
      },
      {
        namespace = "production"
        labels = {
          compute-type = "fargate"
        }
      }
    ]
  }
}
```

## Cost Optimization

### Fargate Benefits
- **Pay-per-pod**: Only pay for resources pods actually use
- **No instance management**: AWS manages the underlying infrastructure
- **Automatic scaling**: Pods start instantly without waiting for nodes
- **No idle capacity**: No wasted compute when pods aren't running

### Node Group Efficiency
- **Minimal footprint**: Only 1-3 small instances for system components
- **Taints prevent waste**: Regular workloads can't schedule on expensive nodes
- **Shared system components**: One node group serves the entire cluster

## Workload Scheduling

### System Components (Node Group)
- AWS Load Balancer Controller
- ExternalDNS
- EBS CSI Driver
- VPC CNI pods
- Any pods that require node access

### Application Workloads (Fargate)
- Web applications
- API services
- Batch jobs
- Microservices
- Any stateless applications

## Usage Examples

### Deploy to Fargate (default namespace)
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: default
spec:
  template:
    metadata:
      labels:
        fargate: "enabled"  # Required for Fargate scheduling
    spec:
      containers:
      - name: app
        image: nginx:latest
```

### Deploy to Fargate (applications namespace)
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-service
  namespace: applications  # Automatically runs on Fargate
spec:
  template:
    spec:
      containers:
      - name: api
        image: my-api:latest
```

### Deploy to Node Group (system components)
```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: system-component
  namespace: kube-system
spec:
  template:
    spec:
      tolerations:
      - key: "CriticalAddonsOnly"
        operator: "Equal"
        value: "true"
        effect: "NoSchedule"
      containers:
      - name: component
        image: system-component:latest
```

## Validation Commands

### Check Fargate Profiles
```bash
kubectl get nodes -l eks.amazonaws.com/compute-type=fargate
aws eks describe-fargate-profile --cluster-name fargate-eks-cluster --fargate-profile-name fargate-eks-cluster-default-profile
```

### Check Node Groups
```bash
kubectl get nodes -l role=system
kubectl describe node <node-name>
```

### Verify Workload Placement
```bash
# Check where pods are running
kubectl get pods -A -o wide

# Check Fargate pods
kubectl get pods -n default -o wide
kubectl get pods -n applications -o wide

# Check system pods
kubectl get pods -n kube-system -o wide
```

## Troubleshooting

### Common Issues

1. **Pods stuck in Pending**: Check if they match Fargate selectors
2. **PVC mount failures**: Ensure EBS CSI driver is running on node group
3. **DNS resolution issues**: Verify CoreDNS is running on Fargate
4. **Load balancer issues**: Check ALB controller logs on node group

### Debug Commands
```bash
# Check Fargate profile status
kubectl describe fargate-profile

# Check node group status
kubectl describe nodes -l role=system

# Check system component logs
kubectl logs -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller
kubectl logs -n kube-system -l app.kubernetes.io/name=external-dns
```

## Next Steps

1. **Deploy applications**: Use the provided examples to deploy workloads
2. **Set up monitoring**: Add Prometheus/Grafana for observability
3. **Configure GitOps**: Use Flux CD for automated deployments
4. **Add more profiles**: Create additional Fargate profiles for different environments
5. **Optimize costs**: Monitor usage and adjust node group sizes

This configuration provides a production-ready, cost-optimized EKS cluster with the flexibility of Fargate and the performance of managed nodes where needed.