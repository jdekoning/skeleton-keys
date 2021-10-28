data "aws_route53_zone" "skeleton_key" {
  name = var.haunted_house_domain
}

resource "aws_acm_certificate" "skeleton_key" {
  domain_name       = data.aws_route53_zone.skeleton_key.name
  validation_method = "DNS"
  subject_alternative_names = ["boundary.${var.haunted_house_domain}", "vault.${var.haunted_house_domain}"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "validation" {
  for_each = {
    for dvo in aws_acm_certificate.skeleton_key.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.skeleton_key.zone_id
}

resource "aws_acm_certificate_validation" "default" {
  certificate_arn         = aws_acm_certificate.skeleton_key.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}

resource "aws_route53_record" "boundary_A" {
  for_each = toset( [
    data.aws_route53_zone.skeleton_key.name,
    "boundary.${data.aws_route53_zone.skeleton_key.name}",
    "vault.${data.aws_route53_zone.skeleton_key.name}",
  ] )

  zone_id = data.aws_route53_zone.skeleton_key.zone_id
  name    = each.key
  type    = "A"

  alias {
    name                   = aws_lb.controller.dns_name
    zone_id                = aws_lb.controller.zone_id
    evaluate_target_health = false
  }
}
