resource "aws_launch_template" "main" {
  name_prefix   = "${var.group_name}-lt"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type

  user_data = base64encode(file("${path.module}/user_data.sh"))

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.ec2.id]
  }

  tags = { Name = "${var.group_name}-launch-template" }
}

resource "aws_autoscaling_group" "main" {
  name = "${var.group_name}-asg"

  vpc_zone_identifier = aws_subnet.private[*].id

  desired_capacity = var.asg_desired_capacity
  min_size         = var.asg_min_size
  max_size         = var.asg_max_size

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  target_group_arns         = [aws_lb_target_group.main.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 120

  tag {
    key                 = "Name"
    value               = "${var.group_name}-asg-instance"
    propagate_at_launch = true
  }
}