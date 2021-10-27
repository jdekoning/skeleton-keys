resource "aws_lb" "boundary_controller" {
  name               = "boundary-controller"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.boundary-ssh.id]
  subnets            = aws_subnet.boundary.*.id
  idle_timeout       = 10
  ip_address_type    = "dualstack"

  access_logs {
    bucket  = aws_s3_bucket.haunted_house_skeletons_access_logs.bucket
    prefix  = "boundary_controller_lb"
    enabled = true
  }

}

resource "aws_lb_listener" "boundary_controller" {
  load_balancer_arn = aws_lb.boundary_controller.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate_validation.boundary.certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Boundary Controller Listener"
      status_code  = "200"
    }
  }
}

resource "aws_lb_listener_rule" "boundary_controller" {
  listener_arn = aws_lb_listener.boundary_controller.arn
  priority     = 100
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.boundary_controller.arn
  }
  condition {
    path_pattern {
      values = [var.boundary_path_pattern]
    }
  }
}

resource "aws_lb_target_group" "boundary_controller" {
  name        = "boundary-controller"
  protocol    = "HTTP"
  port        = var.boundary_api_port
  target_type = "instance"
  vpc_id      = aws_vpc.boundary.id
}

# For the one paying attention, AWS does not validate certificates, OR DOES IT?!
resource "aws_alb_target_group_attachment" "physical_boundary_controller" {
  target_group_arn = aws_lb_target_group.boundary_controller.arn
  target_id        = aws_instance.boundary_controller.id
  port             = var.boundary_api_port
}

##TODO implement https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/load_balancer_policy
#
#resource "aws_load_balancer_policy" "boundary-ca-pubkey-policy" {
#  load_balancer_name = aws_lb.boundary_controller.name
#  policy_name        = "boundary-ca-pubkey-policy"
#  policy_type_name   = "PublicKeyPolicyType"
#
#  # The public key of a CA certificate file can be extracted with:
#  # $ cat wu-tang-ca.pem | openssl x509 -pubkey -noout | grep -v '\-\-\-\-' | tr -d '\n' > wu-tang-pubkey
#  policy_attribute {
#    name  = "PublicKey"
#    value = file(tls_self_signed_cert.boundary_ca_cert.cert_pem)
#  }
#}
#
#resource "aws_load_balancer_policy" "boundary-ca-backend-auth-policy" {
#  load_balancer_name = aws_lb.boundary_controller.name
#  policy_name        = "boundary-ca-backend-auth-policy"
#  policy_type_name   = "BackendServerAuthenticationPolicyType"
#
#  policy_attribute {
#    name  = "PublicKeyPolicyName"
#    value = aws_load_balancer_policy.boundary-ca-pubkey-policy.policy_name
#  }
#}
#
#resource "aws_load_balancer_policy" "boundary-ssl" {
#  load_balancer_name = aws_lb.boundary_controller.name
#  policy_name        = "boundary-ssl"
#  policy_type_name   = "SSLNegotiationPolicyType"
#
#  policy_attribute {
#    name  = "ECDHE-ECDSA-AES128-GCM-SHA256"
#    value = "true"
#  }
#
#  policy_attribute {
#    name  = "Protocol-TLSv1.2"
#    value = "true"
#  }
#}
#
#resource "aws_load_balancer_policy" "boundary-ssl-tls-1-1" {
#  load_balancer_name = aws_lb.boundary_controller.name
#  policy_name        = "boundary-ssl"
#  policy_type_name   = "SSLNegotiationPolicyType"
#
#  policy_attribute {
#    name  = "Reference-Security-Policy"
#    value = "ELBSecurityPolicy-TLS-1-1-2017-01"
#  }
#}
#
#resource "aws_load_balancer_backend_server_policy" "boundary-backend-auth-policies-443" {
#  load_balancer_name = aws_lb.boundary_controller.name
#  instance_port      = 443
#
#  policy_names = [
#    aws_load_balancer_policy.boundary-ca-backend-auth-policy.policy_name,
#  ]
#}
#
#resource "aws_load_balancer_listener_policy" "boundary-listener-policies-443" {
#  load_balancer_name = aws_lb.boundary_controller.name
#  load_balancer_port = 443
#
#  policy_names = [
#    aws_load_balancer_policy.boundary-ssl.policy_name,
#  ]
#}

