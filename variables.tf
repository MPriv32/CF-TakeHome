variable "region" {
  default     = "us-west-2"
  description = "AWS region"
}

variable "azs" {
  type        = number
  default     = 3
  description = "Number of azs"
}

variable "name" {
  default     = "coalfire"
  description = "prefix name for every resource"
}

variable "key_name" {
  type    = string
  default = "bastionkey"
  description = "Name of public ssh key"
}

