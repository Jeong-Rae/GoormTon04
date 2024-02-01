# Web ALB
resource "aws_lb" "web-lb" {
  name               = "web-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.goorm-sg.id]
  subnets            = [aws_subnet.web-public-subnet-a.id, aws_subnet.web-public-subnet-c.id]
}

# Web ALB Target Group
resource "aws_lb_target_group" "web-tg" {
  name     = "web-target-group"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.goorm-vpc.id
}

# Web ALB Listener
resource "aws_lb_listener" "web-lb-listener" {
  load_balancer_arn = aws_lb.web-lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-tg.arn
  }
}

