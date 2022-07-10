output "asg_group_name" {
  value = module.eks_managed_node_group.node_group_autoscaling_group_names[0]
}
