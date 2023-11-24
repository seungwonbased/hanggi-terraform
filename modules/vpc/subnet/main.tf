resource "aws_subnet" "subnet" {
  vpc_id                  = var.vpc_id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, var.index)
  availability_zone       = var.az
  map_public_ip_on_launch = var.public_ip
}


output "id" {
  value = aws_subnet.subnet.id
}

