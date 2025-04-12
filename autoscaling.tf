resource "aws_autoscaling_group" "webapp_asg" {
  name                = "webapp-asg"
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity
  force_delete        = true
  default_cooldown    = 60
  vpc_zone_identifier = [for s in aws_subnet.public_subnet : s.id]


  target_group_arns = [aws_lb_target_group.webapp_tg.arn]



  launch_template {
    id      = aws_launch_template.webapp_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "WebApp-ASG-Instance"
    propagate_at_launch = true
  }
  lifecycle {
    create_before_destroy = true
  }



  # health_check_type         = "EC2"
  # health_check_grace_period = var.health_check_grace_period


}

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "webapp-scale-up"
  autoscaling_group_name = aws_autoscaling_group.webapp_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 60

}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "cpu_high_alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = var.scaleup_threshold # If CPU > 5%, scale up
  alarm_actions       = [aws_autoscaling_policy.scale_up.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webapp_asg.name
  }
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "webapp-scale-down"
  autoscaling_group_name = aws_autoscaling_group.webapp_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 60

}
resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "cpu_low_alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = var.scaledown_threshold # If CPU < 3%, scale down
  alarm_actions       = [aws_autoscaling_policy.scale_down.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webapp_asg.name
  }
}