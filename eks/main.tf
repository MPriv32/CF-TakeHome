resource "aws_eks_cluster" "eks" {

  name     = "${var.name}-eks-cluster"
  role_arn = aws_iam_role.eks_cluster.arn

  #Specifies the version of kubernetes to run
  version = var.k8s_version

  #
  vpc_config {
    endpoint_private_access = false
    endpoint_public_access  = true
    subnet_ids = [
      var.private_subnets[0],
      var.private_subnets[1],
      var.private_subnets[2],
    ]
  }
  depends_on = [
    aws_iam_role_policy_attachment.amazon_eks_cluster_policy
  ]
}

#Creates the IAM role for the cluster w/ the EKS cluster policy below
resource "aws_iam_role" "eks_cluster" {
  name = "${var.name}-eks-cluster-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "amazon_eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}



module "self_managed_node_group" {
  source = "terraform-aws-modules/eks/aws//modules/self-managed-node-group"

  name                = "${var.name}-selfmanaged"
  cluster_name        = aws_eks_cluster.eks.id
  cluster_version     = var.k8s_version
  cluster_endpoint    = aws_eks_cluster.eks.endpoint
  cluster_auth_base64 = aws_eks_cluster.eks.certificate_authority[0].data

  vpc_id = var.vpc_id
  subnet_ids = [
    var.private_subnets[0],
    var.private_subnets[1],
    var.private_subnets[2],
  ]
  #Assigns the node-group security group to the nodes
  vpc_security_group_ids = [
    aws_security_group.node-sg.id
  ]

  min_size     = 3
  max_size     = 6
  desired_size = 3

  key_name            = var.bastion_ssh_key
  security_group_name = "node-sg"

  launch_template_name = aws_launch_template.node.id
  instance_type        = var.node_instance_type
}

resource "aws_security_group" "node-sg" {
  name   = "${var.name}-node-security-group"
  vpc_id = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = 22
    to_port         = 22
    security_groups = [var.bastion_sg]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_template" "node" {

  image_id      = var.node_image_id
  instance_type = var.node_instance_type
  key_name      = var.bastion_ssh_key
  name          = "${var.name}-node-lt"
  user_data = base64encode(templatefile("${path.module}/linux_user_data.tpl", {
    cluster_name = aws_eks_cluster.eks.name
  }))

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = var.node_volume_size
    }
  }
}