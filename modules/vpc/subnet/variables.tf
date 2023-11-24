variable "az" {
  description = "The availability zone for the subnet"
}


variable "index" {
  description = "The index of the CIDR block"
}


variable "vpc_id" {
  description = "The ID of the VPC where the subnet will be created"
}


variable "vpc_cidr" {
  description = "The CIDR block of the VPC"
}


variable "public_ip" {
  description = "Public IP"
  type = bool
  default = false
}