# Launch Template
resource "aws_launch_template" "web-lt" {
  name_prefix   = "web-lt-"
  image_id      = "ami-0bc4327f3aabf5b71"
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.goorm-sg.id]

  user_data = base64encode(<<-EOF
                #!/bin/bash
                JENKINS_SSH_PUBLIC_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDEmHIsGBDbrtKIvmfb+XwKWnCKp5tsc0pI3l4UKdwBvWsukPLYdWETooUuEQDiKtu143L6HRHoatbz7LWjkj2hnH1/a4iLBjIA4GWldlLUhgn/kC9rfehRL+yXRXY5tUIqbVNbcOWUrBJq7cEt+SlCDLOCLIS2WCIk7eOPai8Zk+yq4VeOyf+LpoLhTsUwB2uf2UdRmrddMDOhb4nv6+fX2ncOrPaH0ROv0CP5zITN4vKvwQYfOHnKqPTbGc0LhKOg7g9Z4Dl5DDcDze0rb7PKbnIOwkAKfUfxK5SfZvQ3Tu0SmZrz28s5sR/PmPvMVqJJhuVR05KSiXinML7ZVarZh6OKNanGmtllJJMl4RqN0vwGDaDkmhskAxOL/4jmUrepS2WyM3WxTKybONonMDVJTReD0scqxk7a+d0WiRXQr3hsz5Aa0wp3wJGaZ5+JsSi1JvxDQnWUZq7qL7vJ3ZZLSdV+j3uiYsdPc93/GI61ShJLHP2RfSZVL6iy9KtIQJ0= jeongrae@JeongRae-MacBookPro.local"
                echo $JENKINS_SSH_PUBLIC_KEY >> ~ec2-user/.ssh/authorized_keys
                EOF
             )
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
