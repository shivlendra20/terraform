# Create LoadBalancer
resource "aws_lb" "example_alb" {
  name               = "${local.common_tags.service_initial_name}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.security_group.id]
  subnets            = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]

  tags = {
    Environment = "terraform"
  }
}

# Create TG with relevant port
resource "aws_alb_target_group" "app" {
    name        = "${local.common_tags.service_initial_name}-tg"
    target_type = "ip"
    port        = 80
    protocol    = "HTTP"
    vpc_id      = aws_vpc.new_vpc.id
    
    health_check {
        healthy_threshold   = "3"
        interval            = "30"
        protocol            = "HTTP"
        matcher             = "200"
        timeout             = "3"
        path                = "/"
        unhealthy_threshold = "2"
    }
}

# Create rules for LoadBalancer and provide relevant TG
resource "aws_alb_listener" "http_listener" {
  load_balancer_arn = aws_lb.example_alb.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.app.id
    type             = "forward"
  }
}

