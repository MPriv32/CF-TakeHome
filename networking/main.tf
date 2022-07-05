module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.12.0"

  name                   = "${var.name}-vpc"
  cidr                   = var.vpc_cidr
  azs                    = var.azs
  private_subnets        = var.private_cidrs
  public_subnets         = var.public_cidrs
  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = false

  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }

}

resource "aws_lb" "lb" {
  name               = "${var.name}-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_http.id]
  subnets = [
    module.vpc.private_subnets[0],
    module.vpc.private_subnets[1],
    module.vpc.private_subnets[2],
  ]
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow http inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_http"
  }
}

#attaches the target group with the ASG
resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = var.asg_group_name
  lb_target_group_arn    = aws_lb_target_group.target_group.arn
}

#target group to receive traffic from the ALB listener
resource "aws_lb_target_group" "target_group" {
  name     = "${var.name}-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
}

#forwards traffic from the ALB to our target group
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}