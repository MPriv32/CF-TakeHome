variable "name" {
  type = string
}

variable "vpc_cidr" {
  type = string
  default = "10.1.0.0/16"
}

variable "azs" {
  type = list
  default = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "private_cidrs" {
  type = list
  default = ["10.1.0.0/19", "10.1.32.0/19", "10.1.64.0/19"]
}

variable "public_cidrs" {
  type = list
  default = ["10.1.128.0/20", "10.1.144.0/20", "10.1.160.0/20"]
}

variable "cluster_name" {
    type = string
  default = "coalfire-cluster"
}

variable "asg_group_name" {
  type = string
}