##Creating Load Balancer Target Group
resource "aws_lb_target_group" "webtarget_group" {
  name     = "${var.application_name_prefix}-Web-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

##Attaching Load Balancer TG to the LB
resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = var.autoscaling_group_id
  lb_target_group_arn    = aws_lb_target_group.webtarget_group.arn

  depends_on = [
    aws_lb.webload_balancer
  ]
}

##Creating Port 80 Listener
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.webload_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webtarget_group.arn
  }

  depends_on = [
    aws_lb.webload_balancer
  ]
}

##Creating Load Balancers
resource "aws_lb" "webload_balancer" {
  name               = "${var.application_name_prefix}-LB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_http.id]
  subnets            = var.target_subnets

  enable_deletion_protection = false

  tags = {
    Name        = "${var.application_name_prefix}-LB"
    Environment = var.loadbalancer_environment
  }
}

## Custom Security Group for Load Balancer
resource "aws_security_group" "allow_http" {
  name        = "${var.application_name_prefix}-LB-SG"
  description = "Allow HTTP inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.application_name_prefix}-LB-SG"
  }
}