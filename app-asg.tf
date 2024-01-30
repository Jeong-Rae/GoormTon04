# App Launch Template
resource "aws_launch_template" "app-lt" {
  name_prefix   = "app-lt-"
  image_id      = "ami-0bc4327f3aabf5b71"
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.goorm-sg.id]
}

# App Auto Scaling Group
resource "aws_autoscaling_group" "app-asg" {
  name = "app-asg"

  launch_template {
    id      = aws_launch_template.app-lt.id
    version = "$Latest"
  }

  vpc_zone_identifier     = [aws_subnet.app-private-subnet-a.id, aws_subnet.app-private-subnet-c.id]
  min_size                = 1
  max_size                = 3
  desired_capacity        = 1
  health_check_type       = "EC2"
  health_check_grace_period = 300
  target_group_arns       = [aws_lb_target_group.app-tg.arn]
  force_delete            = true

  tag {
    key                 = "Name"
    value               = "app-instance"
    propagate_at_launch = true
  }
}
