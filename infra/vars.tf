variable "name" {}
variable "region" {}
variable "sourcevpc" {}
variable "targetvpc" {}
variable "instance_name" {}

variable "subnet1" {
  default = "10.0.0.0/24"
}
variable "subnet2" {
  default = "10.0.1.0/24"
}
variable "cidr_block" {
  default = "10.0.0.0/16"
}
variable "enable_dns_hostnames" {
  default = false
}

variable "ami_type" {
  default = "ubuntu"
}

variable "cluster_name" {
  description = "Name of the EKS cluster.  Example: rotate"
}
