resource "aws_lb" "nginx-lb" {
  name               = "nginx-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.public1.id, aws_subnet.public2.id]
  security_groups    = [aws_security_group.default.id]

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_target_group" "nginx-lb" {
  name     = "nginx-lb"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  stickiness {
    type = "lb_cookie"
  }

}

resource "aws_lb_listener" "nginx-lb" {
  load_balancer_arn = aws_lb.nginx-lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx-lb.arn
  }

}