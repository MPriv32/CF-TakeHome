module "s3" {
  source = "./storage"
  name   = var.name
}

module "networking" {
  source = "./networking"
  name   = var.name

  asg_group_name = module.eks.asg_group_name
}

module "eks" {
  source = "./eks"
  name   = var.name
  key_name = module.bastion.key_name
  bastion_sg = module.bastion.bastion_sg_id
  bastion_ssh_key = module.bastion.bastion_ssh_key
  vpc_id = module.networking.vpc_id
  private_subnets = module.networking.vpc_private_subnets
}

module "bastion" {
  source = "./bastion"
  name = var.name
  vpc_id = module.networking.vpc_id
  public_subnets = module.networking.vpc_public_subnets
}