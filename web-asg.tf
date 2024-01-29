# Web ALB 생성
resource "aws_lb" "web-lb" {
  name               = "web-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.goorm-sg.id]
  subnets            = [aws_subnet.web-public-subnet-a.id, aws_subnet.web-public-subnet-c.id]

  enable_deletion_protection = false
}

# Web ALB 리스너 설정
resource "aws_lb_listener" "web_lb_listener" {
  load_balancer_arn = aws_lb.web-lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-tg.arn
  }
}

# Web ALB 설정
resource "aws_lb_target_group" "web-tg" {
  name     = "web-target-group"
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

# Launch Configuration 설정
resource "aws_launch_configuration" "web-lc" {
  name_prefix   = "web-lc-"
  image_id      = "ami-0bc4327f3aabf5b71" 
  instance_type = "t2.micro"
  security_groups = [aws_security_group.goorm-sg.id]

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group 설정
resource "aws_autoscaling_group" "web-asg" {
  launch_configuration    = aws_launch_configuration.web-lc.id
  vpc_zone_identifier     = [aws_subnet.web-public-subnet-a.id, aws_subnet.web-public-subnet-c.id]
  min_size                = 1
  max_size                = 3
  desired_capacity        = 1
  health_check_type       = "ELB"
  health_check_grace_period = 300
  target_group_arns       = [aws_lb_target_group.web-tg.arn]
  force_delete            = true

  tag {
    key                 = "Name"
    value               = "web-instance"
    propagate_at_launch = true
  }
}
