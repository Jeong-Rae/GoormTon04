# Launch Template
resource "aws_launch_template" "web-lt" {
  name_prefix   = "web-lt-"
  image_id      = "ami-0bc4327f3aabf5b71"
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.goorm-sg.id]
}

# Auto Scaling Group 설정
resource "aws_autoscaling_group" "web-asg" {
  name = "web-asg"

  launch_template {
    id      = aws_launch_template.web-lt.id
    version = "$Latest"
  }

  vpc_zone_identifier     = [aws_subnet.web-public-subnet-a.id, aws_subnet.web-public-subnet-c.id]
  min_size                = 1
  max_size                = 3
  desired_capacity        = 1
  health_check_type       = "EC2"
  health_check_grace_period = 300
  target_group_arns       = [aws_lb_target_group.web-tg.arn]
  force_delete            = true

  tag {
    key                 = "Name"
    value               = "web-instance"
    propagate_at_launch = true
  }
}
