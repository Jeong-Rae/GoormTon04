# App NLB
resource "aws_lb" "app-lb" {
  name               = "app-lb"
  load_balancer_type = "network"
  security_groups    = [aws_security_group.goorm-sg.id]
  subnets            = [aws_subnet.app-private-subnet-a.id, aws_subnet.app-private-subnet-c.id]
}

# App NLB Target Group
resource "aws_lb_target_group" "app-tg" {
  name     = "app-target-group"
  protocol = "TCP"
  port = 8080
  vpc_id   = aws_vpc.goorm-vpc.id
}

# App NLB Listener
resource "aws_lb_listener" "app-lb-listener" {
  load_balancer_arn = aws_lb.app-lb.arn
  protocol          = "TCP"
  port              = 8080 

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app-tg.arn
  }
}