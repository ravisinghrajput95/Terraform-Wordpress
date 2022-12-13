resource "aws_autoscaling_group" "web-server" {
  name                 = "nginx-asg"
  max_size             = 2
  min_size             = 2
  desired_capacity     = 2
  force_delete         = true
  launch_configuration = aws_launch_configuration.web-server-launch-config.name
  vpc_zone_identifier  = [aws_subnet.public1.id, aws_subnet.public2.id]
  tag {
    key                 = "Name"
    value               = "Webserver"
    propagate_at_launch = true
  }
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [load_balancers, target_group_arns]

  }
}
# Create a new ALB Target Group attachment
resource "aws_autoscaling_attachment" "nginx-lb" {
  autoscaling_group_name = aws_autoscaling_group.web-server.id
  lb_target_group_arn    = aws_lb_target_group.nginx-lb.arn
}

resource "aws_launch_configuration" "web-server-launch-config" {
  name_prefix          = "web_config"
  image_id             = data.aws_ami.ubuntu.id #"ami-05c16fac4acebb3cc" #
  instance_type        = "t3.micro"
  key_name             = "ansible"
  iam_instance_profile = aws_iam_instance_profile.test_profile.id
  security_groups      = [aws_security_group.default.id]

  user_data = data.template_file.asg_init.rendered
  lifecycle {
    create_before_destroy = true
  }
}
data "template_file" "asg_init" {
  template = file("${path.module}/userdata.tpl")
  vars = {
    db_name = var.db_name
    db_pass = var.db_pass
    db_user = var.db_user
    db_host = aws_db_instance.wordpress.address
    efs_id  = aws_efs_file_system.wordpress-efs.id
  }
}