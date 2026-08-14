# Basic EKS Cluster Example

Minimal EKS cluster with a single on-demand managed node group. No add-ons
(Fluent Bit, Load Balancer Controller, ExternalDNS, Route53 zones) — use this
as the starting point, or see `../advanced` for a fuller-featured deployment,
or `../argo-cd`, `../fargate`, `../flux-cd`, `../on-demand`, `../spot` for
specific deployment patterns.

```bash
tofu init
tofu plan
```
