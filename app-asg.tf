# Application Load Balancer (ALB)의 Target Group 생성
resource "aws_lb_target_group" "app-tg" {
  name     = "app-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.goorm-vpc.id

  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Application Load Balancer 생성
resource "aws_lb" "app-lb" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.goorm-sg.id]
  subnets            = [aws_subnet.app-private-subnet-a.id, aws_subnet.app-private-subnet-c.id]

  enable_deletion_protection = false
}

# Load Balancer Listener 설정
resource "aws_lb_listener" "app_lb_listener" {
  load_balancer_arn = aws_lb.app-lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app-tg.arn
  }
}

# Launch Configuration 생성
resource "aws_launch_configuration" "app-lc" {
  name_prefix   = "app-lc-"
  image_id      = "ami-0bc4327f3aabf5b71" 
  instance_type = "t2.micro"
  security_groups = [aws_security_group.goorm-sg.id]

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group 생성
resource "aws_autoscaling_group" "app-asg" {
  launch_configuration    = aws_launch_configuration.app-lc.id
  vpc_zone_identifier     = [aws_subnet.app-private-subnet-a.id, aws_subnet.app-private-subnet-c.id]
  min_size                = 1
  max_size                = 3
  desired_capacity        = 1
  health_check_type       = "ELB"
  health_check_grace_period = 300
  target_group_arns       = [aws_lb_target_group.app-tg.arn]
  force_delete            = true

  tag {
    key                 = "Name"
    value               = "app-instance"
    propagate_at_launch = true
  }
}
