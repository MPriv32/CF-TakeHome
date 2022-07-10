module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.0"

  cluster_name    = var.name
  cluster_version = var.k8s_version

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  create_cluster_security_group = false
  create_node_security_group  = false
  cluster_security_group_id = aws_security_group.cluster_sg.id
  node_security_group_id = aws_security_group.node_sg.id

  create_iam_role = false
  iam_role_arn = aws_iam_role.eks_cluster.arn


  vpc_id     = var.vpc_id
  subnet_ids = [
    var.private_subnets[0],
    var.private_subnets[1],
    var.private_subnets[2],
  ]

    depends_on = [
    aws_iam_role_policy_attachment.amazon_eks_cluster_policy,
  ]

}

module "eks_managed_node_group" {
  source = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"

  name            = "${var.name}-eks-mng"
  cluster_name    = module.eks.cluster_id
  cluster_version = var.k8s_version

  vpc_id     = var.vpc_id
  subnet_ids = [
    var.private_subnets[0],
    var.private_subnets[1],
    var.private_subnets[2],
  ]

  create_security_group = false
  # The following variables are necessary if you decide to use the module outside of the parent EKS module context.
  # Without it, the security groups of the nodes are empty and thus won't join the cluster.
  cluster_primary_security_group_id = aws_security_group.node_sg.id
  cluster_security_group_id = aws_security_group.cluster_sg.id

  min_size     = 3
  max_size     = 6
  desired_size = 3

  instance_types = [var.node_instance_type]
  capacity_type  = "SPOT"
  disk_size = 20

  user_data_template_path = "${path.module}/node_user_data.tpl"

  key_name            = var.bastion_ssh_key

}

resource "aws_security_group" "cluster_sg" {
  name   = "${var.name}-cluster-security-group"
  vpc_id = var.vpc_id

  ingress {
    protocol        = -1
    from_port       = 0
    to_port         = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "node_sg" {
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
