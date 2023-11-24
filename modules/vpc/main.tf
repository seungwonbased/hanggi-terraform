provider "aws" {
  region = "us-west-2"
}


resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}


resource "aws_internet_gateway" "vpc_igw" {
  vpc_id = aws_vpc.main.id
}


resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_igw.id
  }
}


resource "aws_route_table_association" "public_subnet_bastion_association" {
  subnet_id      = module.subnet_public_bastion.id
  route_table_id = aws_route_table.public_route_table.id
}


resource "aws_route_table_association" "public_subnet_a_association" {
  subnet_id      = module.subnet_public_a.id
  route_table_id = aws_route_table.public_route_table.id
}


resource "aws_route_table_association" "public_subnet_b_association" {
  subnet_id      = module.subnet_public_b.id
  route_table_id = aws_route_table.public_route_table.id
}


resource "aws_eip" "bastion-eip" {
  instance = var.instance_id
}


module "subnet_public_bastion" {
  source = "./subnet"
  az     = "us-west-2a"
  index  = 5
  vpc_cidr = aws_vpc.main.cidr_block
  vpc_id = aws_vpc.main.id
  public_ip = true
}


module "subnet_public_a" {
  source  = "./subnet"
  az      = "us-west-2a"
  index   = 1
  vpc_id  = aws_vpc.main.id
  vpc_cidr = aws_vpc.main.cidr_block
  public_ip = true
}


module "subnet_private_a" {
  source  = "./subnet"
  az      = "us-west-2a"
  index   = 2
  vpc_id  = aws_vpc.main.id
  vpc_cidr = aws_vpc.main.cidr_block
}


module "subnet_public_b" {
  source  = "./subnet"
  az      = "us-west-2b"
  index   = 3
  vpc_id  = aws_vpc.main.id
  vpc_cidr = aws_vpc.main.cidr_block
  public_ip = true
}


module "subnet_private_b" {
  source  = "./subnet"
  az      = "us-west-2b"
  index   = 4
  vpc_id  = aws_vpc.main.id
  vpc_cidr = aws_vpc.main.cidr_block
}


output "vpc_id" {
  value = aws_vpc.main.id
}


output "subnet_1_a_id" {
  value = module.subnet_public_a.id
}


output "subnet_1_b_id" {
  value = module.subnet_public_b.id
}


output "subnet_2_a_id" {
  value = module.subnet_private_a.id
}


output "subnet_2_b_id" {
  value = module.subnet_private_b.id
}


output "public_subnet_bastion_id" {
  value = module.subnet_public_bastion.id
}