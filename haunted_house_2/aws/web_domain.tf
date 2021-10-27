data "aws_route53_zone" "skeleton_key" {
  name = var.haunted_house_domain
}

resource "aws_acm_certificate" "skeleton_key" {
  domain_name       = data.aws_route53_zone.skeleton_key.name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "validation" {
  name    = tolist(aws_acm_certificate.skeleton_key.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.skeleton_key.domain_validation_options)[0].resource_record_type
  zone_id = data.aws_route53_zone.skeleton_key.zone_id
  records = [tolist(aws_acm_certificate.skeleton_key.domain_validation_options)[0].resource_record_value]
  ttl     = "60"
}

resource "aws_acm_certificate_validation" "default" {
  certificate_arn         = aws_acm_certificate.skeleton_key.arn
  validation_record_fqdns = [aws_route53_record.validation.fqdn]
}

resource "aws_route53_record" "boundary" {
  zone_id = data.aws_route53_zone.skeleton_key.zone_id
  name    = data.aws_route53_zone.skeleton_key.name
  type    = "A"

  alias {
    name                   = aws_lb.controller.dns_name
    zone_id                = aws_lb.controller.zone_id
    evaluate_target_health = false
  }
}
