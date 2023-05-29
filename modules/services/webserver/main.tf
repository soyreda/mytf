module "ec2-instance" {

  source        = "terraform-aws-modules/ec2-instance/aws"
  ami           = "ami-0fcf52bcf5db7b003"
  version       = "5.0.0"
  instance_type = var.instance_type
  name          = "single-instance"

}
resource "aws_launch_configuration" "example" {
  image_id        = "ami-0fcf52bcf5db7b003"
  instance_type   = var.instance_type
  security_groups = [aws_security_group.instance.id]
  user_data       = file("userdata.tpl")
  #user_data_replace_on_change = true
  #tags = {
  # Name = "terraform-example"
  #}
}
resource "aws_autoscaling_group" "example" {
  # name                 = "terraform-asg-example"
  launch_configuration = aws_launch_configuration.example.name
  vpc_zone_identifier  = data.aws_subnets.default.ids
  min_size             = var.min_size
  max_size             = var.max_size
  dynamic "tag" {
	for_each = var.custom_tags
	content {
key = tag.key
value = tag.value
propagate_at_launch = true	
}
}
  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-asg-example"
    propagate_at_launch = true
  }
  lifecycle {
    create_before_destroy = true
  }
  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"
}
data "aws_vpc" "default" {
  default = true
}
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]

  }
}
resource "aws_security_group" "instance" {
  name = "${var.cluster_name}-instance"
  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
}
resource "aws_lb" "example" {
  name               = "${var.cluster_name}-asg-example"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.alb.id]
}
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port              = local.http_port
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}
resource "aws_security_group" "alb" {
  name = "${var.cluster_name}-alb"

  ingress {
    from_port   = local.http_port
    to_port     = local.http_port
    protocol    = local.tcp_protocol
    cidr_blocks = local.all_ips
  }
  egress {
    from_port   = local.any_port
    to_port     = local.any_port
    protocol    = local.any_protocol
    cidr_blocks = local.all_ips
  }
}
resource "aws_lb_target_group" "asg" {
  name     = "terraform-asg-example"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}
resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100
  condition {
    path_pattern {
      values = ["*"]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}
