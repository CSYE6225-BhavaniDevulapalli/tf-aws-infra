resource "aws_lb" "webapp_alb" {
  name               = "webapp-alb"
  internal           = false # Set to false to make it public-facing
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [for s in aws_subnet.public_subnet : s.id]

  enable_deletion_protection = false

  tags = {
    Name = "WebApp-ALB"
  }
}
resource "aws_lb_target_group" "webapp_tg" {
  name     = "webapp-target-group"
  port     = 8080 # Forward traffic to your web application port
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id

  health_check {
    enabled             = true
    path                = "/healthz"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }


  tags = {
    Name = "WebApp-TargetGroup"
  }
}
resource "aws_autoscaling_attachment" "webapp_asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.webapp_asg.id
  lb_target_group_arn    = aws_lb_target_group.webapp_tg.arn
}

# resource "aws_lb_listener" "webapp_listener" {
#   load_balancer_arn = aws_lb.webapp_alb.arn
#   port              = 80
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.webapp_tg.arn
#   }
# }

