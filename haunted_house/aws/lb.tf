resource "aws_lb" "controller" {
  name               = "boundary-controller"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.controller_lb.id]
  subnets            = aws_subnet.public.*.id
  idle_timeout       = 10
#  ip_address_type    = "dualstack"
}

resource "aws_lb_target_group" "controller" {
  name        = "boundary-controller"
  protocol    = "HTTP"
  port        = 9200
  vpc_id      = aws_vpc.main.id
}

resource "aws_lb_target_group_attachment" "controller" {
  count            = var.num_controllers
  target_group_arn = aws_lb_target_group.controller.arn
  target_id        = aws_instance.controller[count.index].id
  port             = 9200
}

resource "aws_lb_listener" "controller" {
  depends_on        = [aws_acm_certificate_validation.default]
  load_balancer_arn = aws_lb.controller.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.skeleton_key.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.controller.arn
  }
}

resource "aws_lb_listener_rule" "controller" {
  listener_arn = aws_lb_listener.controller.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.controller.arn
  }

  condition {
    host_header {
      values = ["boundary.${var.haunted_house_domain}"]
    }
  }
}

resource "aws_security_group" "controller_lb" {
  name_prefix = "controller_lb"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group_rule" "allow_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.controller_lb.id
}

resource "aws_security_group_rule" "allow_egress_lb" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.controller_lb.id
}

resource "aws_lb_listener_rule" "vault" {
  listener_arn = aws_lb_listener.controller.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vault.arn
  }

  condition {
    host_header {
      values = ["vault.${var.haunted_house_domain}"]
    }
  }
}

resource "aws_lb_target_group" "vault" {
  name        = "vault"
  protocol    = "HTTP"
  port        = 8200
  vpc_id      = aws_vpc.main.id
}

resource "aws_lb_target_group_attachment" "vault" {
  count            = var.num_vaults
  target_group_arn = aws_lb_target_group.vault.arn
  target_id        = aws_instance.vault[count.index].id
  port             = 8200
}
