# EKS Fargate Example

This example demonstrates how to deploy an EKS cluster with AWS Fargate for serverless container execution. This configuration uses a hybrid approach with a small managed node group for system components that require traditional nodes, while using Fargate profiles for application workloads.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         EKS Cluster                           │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────┐  ┌─────────────────────────────────┐   │
│  │   Node Group        │  │        Fargate Profiles         │   │
│  │   (System)          │  │                                 │   │
│  │  ┌─────────────────┐│  │  ┌─────────────────────────────┐│   │
│  │  │ • AWS LB Ctrl   ││  │  │ • Application Pods          ││   │
│  │  │ • ExternalDNS   ││  │  │ • Batch Jobs                ││   │
│  │  │ • EBS CSI       ││  │  │ • Microservices             ││   │
│  │  │ • VPC CNI       ││  │  │ • CoreDNS (kube-system)     ││   │
│  │  └─────────────────┘│  │  └─────────────────────────────┘│   │
│  └─────────────────────┘  └─────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

## What This Example Includes

### Core Infrastructure
- **EKS Cluster** with Kubernetes 1.32
- **Hybrid Compute**: Small node group for system components + Fargate for applications
- **VPC Discovery**: Automatic VPC and subnet discovery using tags
- **Security Groups**: Properly configured for Fargate networking
- **IAM Roles**: IRSA-enabled roles for secure AWS service access

### Fargate Configuration
- **System Node Group**: Minimal node group for components requiring traditional nodes
- **Fargate Profiles**: 
  - Default profile for application namespaces
  - Specific profile for kube-system CoreDNS
  - Applications namespace profile
- **Serverless Execution**: No EC2 instance management required

### DNS and Load Balancing
- **Route53 Integration**: Automatic hosted zone creation and management
- **AWS Load Balancer Controller**: ALB/NLB creation and management
- **ExternalDNS**: Automatic DNS record creation for ingresses and services
- **HTTPS Ready**: Certificate management integration

### Add-ons and Automation
- **EBS CSI Driver**: Persistent volume support (runs on node group)
- **VPC CNI**: Enhanced networking with IRSA
- **Automatic Version Management**: Latest compatible add-on versions
- **Helm Deployments**: Automated deployment of critical components

## Prerequisites

1. **AWS CLI** configured with appropriate permissions
2. **Terraform** >= 1.0
3. **kubectl** for cluster access
4. **Existing VPC** with public/private subnets
5. **Domain Name** (optional, for DNS automation)

### Required AWS Permissions

- EKS cluster management
- EC2 instance and security group management
- IAM role and policy management
- Route53 hosted zone management (if using DNS features)
- ELB and ALB management

## Quick Start

### 1. Configure Variables

Copy and customize the variables:

```bash
cp terraform.tfvars terraform.tfvars.local
```

Edit `terraform.tfvars.local` with your values:

```hcl
# Essential Configuration
region              = "us-west-2"
cluster_name        = "my-fargate-cluster"
vpc_name           = "my-vpc"
public_access_cidrs = ["YOUR_IP_ADDRESS/32"]

# DNS Configuration (optional)
create_hosted_zones = true
hosted_zone_domains = ["your-domain.com"]

# Fargate Profiles
fargate_profiles = {
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

### 2. Deploy the Cluster

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan -var-file=terraform.tfvars.local

# Deploy the cluster
terraform apply -var-file=terraform.tfvars.local
```

### 3. Configure kubectl

```bash
# Get cluster credentials
aws eks update-kubeconfig --region us-west-2 --name my-fargate-cluster

# Verify connectivity
kubectl get nodes
kubectl get pods -A
```

## Fargate Considerations

### What Runs on Fargate
✅ **Application Pods**: Your containerized applications  
✅ **Batch Jobs**: Short-lived computational tasks  
✅ **Microservices**: Stateless services  
✅ **CoreDNS**: Kubernetes DNS (with specific profile)  

### What Runs on Node Group
⚠️ **System Components**: AWS Load Balancer Controller, ExternalDNS  
⚠️ **Storage Drivers**: EBS CSI driver  
⚠️ **Network Add-ons**: VPC CNI components  
⚠️ **Monitoring**: DaemonSets and system monitoring tools  

### Fargate Limitations
- No privileged containers
- No HostNetwork or HostPort
- No DaemonSets
- Limited local storage (20GB ephemeral)
- Fixed compute resources (no burstable instances)

## Configuration Examples

### Application Deployment

Deploy applications to run on Fargate:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-fargate
  namespace: applications
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx-fargate
  template:
    metadata:
      labels:
        app: nginx-fargate
        fargate: enabled  # This label triggers Fargate execution
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        resources:
          requests:
            cpu: 250m
            memory: 512Mi
          limits:
            cpu: 500m
            memory: 1Gi
        ports:
        - containerPort: 80
```

### Service with Load Balancer

Create a service that automatically gets DNS records:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-fargate-service
  namespace: applications
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
    external-dns.alpha.kubernetes.io/hostname: "app.your-domain.com"
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 80
  selector:
    app: nginx-fargate
```

### Ingress with ALB

Create an ingress with automatic ALB and DNS:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-fargate-ingress
  namespace: applications
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    external-dns.alpha.kubernetes.io/hostname: "web.your-domain.com"
spec:
  rules:
  - host: web.your-domain.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx-fargate-service
            port:
              number: 80
```

## Cost Optimization

### Fargate Pricing Model
- **Pay per vCPU/Memory**: Only pay for allocated resources
- **No Node Management**: No EC2 instance costs for applications
- **Automatic Scaling**: No over-provisioning of compute

### Best Practices
1. **Right-size Resources**: Set appropriate CPU/memory requests
2. **Use Spot for Dev**: Consider Fargate Spot for development workloads
3. **Namespace Organization**: Use separate namespaces for different environments
4. **Resource Monitoring**: Monitor actual usage vs. allocated resources

## Monitoring and Troubleshooting

### Check Fargate Pods
```bash
# List all pods and their nodes
kubectl get pods -o wide -A

# Check Fargate profile assignments
kubectl describe node fargate-ip-xxx

# View pod events
kubectl describe pod <pod-name> -n <namespace>
```

### View Fargate Logs
```bash
# View logs from Fargate pods
kubectl logs <pod-name> -n <namespace>

# Stream logs
kubectl logs -f <pod-name> -n <namespace>
```

### Debug Scheduling Issues
```bash
# Check if pods are stuck in Pending
kubectl get pods -A | grep Pending

# Check scheduler events
kubectl get events --sort-by=.metadata.creationTimestamp -A
```

## Scaling and Management

### Horizontal Pod Autoscaler
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: nginx-fargate-hpa
  namespace: applications
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nginx-fargate
  minReplicas: 2
  maxReplicas: 20
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

### Cluster Autoscaler (Node Group)
The system node group uses cluster autoscaler for automatic scaling based on system component needs.

## Cleanup

```bash
# Destroy the cluster and all resources
terraform destroy -var-file=terraform.tfvars.local
```

**Warning**: This will delete all resources including the EKS cluster, node groups, Fargate profiles, and any associated AWS resources.

## Advanced Configuration

### Custom Fargate Profiles
Add custom Fargate profiles for specific workloads:

```hcl
fargate_profiles = {
  batch_jobs = {
    selectors = [
      {
        namespace = "batch"
        labels = {
          workload-type = "batch"
        }
      }
    ]
  }
  
  ml_workloads = {
    selectors = [
      {
        namespace = "ml"
        labels = {
          compute-type = "gpu"  # Note: Fargate doesn't support GPU
        }
      }
    ]
  }
}
```

### Security Considerations
- All Fargate pods run in isolation
- Network policies can be applied
- IAM roles provide fine-grained permissions
- Encryption at rest and in transit

## Troubleshooting

### Common Issues

1. **Pods stuck in Pending**
   - Check Fargate profile selectors
   - Verify namespace and labels match
   - Check resource requests vs. Fargate limits

2. **System components not starting**
   - Ensure node group is running
   - Check taints and tolerations
   - Verify system component selectors

3. **DNS resolution issues**
   - Check CoreDNS is running on Fargate
   - Verify kube-system Fargate profile
   - Check Route53 hosted zone configuration

### Getting Help

- Check the main [README.md](../../README.md) for module documentation
- Review [TASKFILE.md](../../TASKFILE.md) for development workflows
- Use `terraform plan` to preview changes before applying

## Example Outputs

After successful deployment, you'll see outputs like:

```
cluster_endpoint = "https://xxxxx.gr7.us-west-2.eks.amazonaws.com"
cluster_name = "my-fargate-cluster"
hosted_zone_ids = {
  "your-domain.com" = "Z1D633PJN98FT9"
}
load_balancer_controller_role_arn = "arn:aws:iam::123456789012:role/..."
```

This Fargate example provides a production-ready, serverless Kubernetes platform with automatic DNS management and load balancing.