# Route53 hosted zones for external-dns integration
resource "aws_route53_zone" "cluster_zones" {
  for_each = var.create_hosted_zones ? toset(var.hosted_zone_domains) : toset([])

  name    = each.value
  comment = "Managed by EKS cluster ${var.cluster_name} for external-dns"

  tags = merge(local.tags, {
    Name                    = each.value
    "kubernetes.io/cluster" = var.cluster_name
    "external-dns/owner"    = var.external_dns_txt_owner_id != null ? var.external_dns_txt_owner_id : var.cluster_name
    ManagedBy               = "terraform"
    Purpose                 = "external-dns"
  })
}

# Optional: Create subdomain zones for better organization
resource "aws_route53_zone" "cluster_subdomains" {
  for_each = var.create_hosted_zones && var.create_subdomain_zones ? toset(var.subdomain_zones) : toset([])

  name    = "${each.value}.${var.primary_domain}"
  comment = "Subdomain zone for EKS cluster ${var.cluster_name}"

  tags = merge(local.tags, {
    Name                    = "${each.value}.${var.primary_domain}"
    "kubernetes.io/cluster" = var.cluster_name
    "external-dns/owner"    = var.external_dns_txt_owner_id != null ? var.external_dns_txt_owner_id : var.cluster_name
    ManagedBy               = "terraform"
    Purpose                 = "external-dns-subdomain"
  })
}

# Create NS records in parent zones for subdomains (if parent zone is managed)
resource "aws_route53_record" "subdomain_ns" {
  for_each = var.create_hosted_zones && var.create_subdomain_zones ? toset(var.subdomain_zones) : toset([])

  zone_id = try(aws_route53_zone.cluster_zones[var.primary_domain].zone_id, var.parent_zone_id)
  name    = "${each.value}.${var.primary_domain}"
  type    = "NS"
  ttl     = 300
  records = aws_route53_zone.cluster_subdomains[each.value].name_servers

  depends_on = [aws_route53_zone.cluster_subdomains]
}

# Local values for zone management
locals {
  # Combine created zones with external zone IDs
  all_zone_ids = concat(
    values(aws_route53_zone.cluster_zones)[*].zone_id,
    values(aws_route53_zone.cluster_subdomains)[*].zone_id,
    var.external_dns_zone_ids
  )

  # All domain names for external-dns configuration
  all_domains = concat(
    var.hosted_zone_domains,
    [for subdomain in var.subdomain_zones : "${subdomain}.${var.primary_domain}"],
    var.external_dns_domain_filters
  )
}
