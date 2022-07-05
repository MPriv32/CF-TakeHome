variable "bastion_instance_type" {
  default     = "t2.micro"
  description = "Specify instance size for the bastion hosts"
}

variable "name" {
  description = "name"
}

variable "public_subnets" {
  description = "public subnets for bastion hosts"
}

variable "vpc_id" {
  description = "VPC id"
}

variable "key_name" {
  type    = string
  default = "bastionkey"
  description = "Name of public ssh key"
}