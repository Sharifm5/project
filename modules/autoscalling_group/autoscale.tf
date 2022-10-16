## Custom Security Group
resource "aws_security_group" "allow_http" {
  name        = "${var.application_name_prefix}-ASG-SG"
  description = "Allow HTTP inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from VPC"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.lb_security_group_id]
  }

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
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
    Name = "${var.application_name_prefix}-ASG-SG"
  }
}

## Configure Apache
data "template_file" "apache-script" {
  template = <<EOF
    #!/bin/bash
    sudo touch /tmp/apache
    sudo yum install httpd -y
    sudo service httpd start
    echo "Welcome to Web Server, Server IP : " >> /var/www/html/index.html
    echo `hostname -i | awk '{print $2}'` >> /var/www/html/index.html
  EOF
}

## Creating Launch Template for Web Servers
resource "aws_launch_template" "webservers-template" {
  name_prefix            = "${var.application_name_prefix}-LC"
  image_id               = var.image_id
  instance_type          = var.instance_type
  key_name               = var.instance_key
  vpc_security_group_ids = [aws_security_group.allow_http.id]

  user_data = base64encode(data.template_file.apache-script.rendered)

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "webservers-asg" {
  name_prefix         = "${var.application_name_prefix}-ASG"
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  min_size            = var.min_size
  vpc_zone_identifier = var.vpc_zone_identifier

  launch_template {
    id      = aws_launch_template.webservers-template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.application_name_prefix}-WebServer"
    propagate_at_launch = true
  }
}