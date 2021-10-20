resource "aws_lb" "boundary_controller" {
  name               = "boundary-controller"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.boundary-ssh.id]
  subnets            = aws_subnet.boundary.*.id
  idle_timeout       = 10
  ip_address_type    = "dualstack"
}

resource "aws_lb_listener" "boundary_controller" {
  depends_on        = [aws_acm_certificate_validation.default]
  load_balancer_arn = aws_lb.boundary_controller.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.skeleton_key.arn

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
  depends_on   = [aws_lb_target_group.boundary_controller]
  listener_arn = aws_lb_listener.boundary_controller.arn
  priority     = 100
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.boundary_controller.id
  }
  condition {
    path_pattern {
      values = [var.boundary_path_pattern]
    }
  }
}

resource "aws_lb_target_group" "boundary_controller" {
  name        = "boundary-controller"
  protocol    = "HTTPS"
  port        = var.boundary_controller_port
  target_type = "instance"
  vpc_id      = aws_vpc.boundary.id
}

# For the one paying attention, AWS does not validate certificates
resource "aws_alb_target_group_attachment" "physical_boundary_controller" {
  target_group_arn = aws_lb_target_group.boundary_controller.arn
  target_id        = aws_instance.boundary_controller.id
  port             = var.boundary_controller_port
}
