variable "db_password" {
  description = "Password of the RDS"
  sensitive = true
}

variable "sg_id" {}

variable "db_name" {
  default = "recipe"
}

variable "db_username" {
  default = "postgres"
}

variable "subnet_1_id" {}

variable "subnet_2_id" {}