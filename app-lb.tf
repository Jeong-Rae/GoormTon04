# App ALB
resource "aws_lb" "app-lb" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.goorm-sg.id]
  subnets            = [aws_subnet.app-private-subnet-a.id, aws_subnet.app-private-subnet-c.id]

  enable_deletion_protection = false
}

# App ALB Target Group
resource "aws_lb_target_group" "app-tg" {
  name     = "app-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.goorm-vpc.id
}

# App ALB Listener
resource "aws_lb_listener" "app-lb-listener" {
  load_balancer_arn = aws_lb.app-lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app-tg.arn
  }
}