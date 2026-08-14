# Advanced EKS Cluster Example

Fuller-featured EKS deployment: mixed on-demand + spot managed node groups,
IRSA, AWS Load Balancer Controller, optional ExternalDNS + Route53 hosted
zones, and Fluent Bit log shipping. See `../basic` for the minimal starting
point, or `../argo-cd`, `../fargate`, `../flux-cd`, `../on-demand`, `../spot`
for specific deployment patterns.

```bash
tofu init
tofu plan
```
