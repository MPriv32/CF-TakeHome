variable "node_instance_type" {
  default     = "t2.micro"
  description = "Specify instance size for EKS nodes"
}

variable "node_volume_size" {
  type        = number
  default     = 20
  description = "The size of the volume in gigabytes for the EKS nodes"
}

variable "node_image_id" {
  type        = string
  default     = "ami-098e42ae54c764c35"
  description = "AMI for the EKS nodes"
}

variable "k8s_version" {
  type        = number
  default     = "1.21"
  description = "Version for the kubernetes cluster"
}

variable "bastion_sg" {
  description = "bastion sg to add to ingress rule of node sg"
}

variable "bastion_ssh_key" {
  description = "SSH key for bastion and nodes"
}
variable "vpc_id" {
  description = "VPC id"
}

variable "private_subnets" {
  type = list
  description = "VPC private subnets"
}

variable "name" {
  description = "name"
}

variable "key_name" {
  type    = string
  default = "bastionkey"
  description = "Name of public ssh key"
}