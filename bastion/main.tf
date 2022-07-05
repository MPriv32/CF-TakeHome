resource "aws_key_pair" "bastion_auth" {
  key_name   = var.key_name
  public_key = file("~/.ssh/bastionkey.pub")
}

resource "aws_autoscaling_group" "bastion_asg" {
  name                      = "${var.name}-bastion-asg"
  max_size                  = 3
  min_size                  = 3
  health_check_grace_period = 60
  health_check_type         = "EC2"
  placement_group           = aws_placement_group.bastion_placement_group.id
  vpc_zone_identifier = [
    var.public_subnets[0],
    var.public_subnets[1],
    var.public_subnets[2],
  ]

  launch_template {
    id      = aws_launch_template.bastion_launch_template.id
    version = "$Default"
  }
}

resource "aws_placement_group" "bastion_placement_group" {
  name     = "${var.name}-bastion-placement-group"
  strategy = "spread"
  tags = {
    Name = "${var.name}-bastion-placement-group"
  }
}

resource "aws_launch_template" "bastion_launch_template" {
  name_prefix   = "${var.name}-bastion-launch-template"
  image_id      = data.aws_ami.AL2_ami.id
  instance_type = var.bastion_instance_type
  key_name      = aws_key_pair.bastion_auth.id

  user_data = filebase64("${path.module}/userdata.tpl")

  vpc_security_group_ids = [aws_security_group.bastion_sg.id]


  tags = {
    Name = "${var.name}-bastion-launch-template"
  }
}

resource "aws_security_group" "bastion_sg" {
  name   = "${var.name}-bastion-security-group"
  vpc_id = var.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-bastion-sg"
  }
}