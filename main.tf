resource "aws_autoscaling_group" "nginx-webserver-autoscaling-group" {
  name                      = "nginx-asg"
  max_size                  = 5
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 4
  launch_configuration      = aws_launch_configuration.nginx-webserver-launch-configuration.name
  vpc_zone_identifier       = ["subnet-0f1e12a685db997f4", "subnet-070c35eeb2bc3a968"]

  tag {
    key                 = "Name"
    value               = "Webserver-asg"
    propagate_at_launch = true
  }

    lifecycle {
    create_before_destroy = true
    ignore_changes        = [load_balancers, target_group_arns]

  }
}

resource "aws_launch_configuration" "nginx-webserver-launch-configuration" {
  name          = "web_launchconfig"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  user_data = <<-EOF
  #!/bin/bash
  apt update
  apt install nginx -y
  service nginx start
  service nginx 
  EOF
}