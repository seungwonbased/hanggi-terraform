terraform {
  backend "s3" {
    bucket         = "hanggi-terraform-state-backend"
    key            = "terraform/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "hanggi-terraform-state-lock"
    encrypt = true
  }
}


module "main_vpc" {
  source      = "./modules/vpc"
  aws_region  = var.region
  vpc_name    = var.vpc_name
  vpc_cidr    = var.vpc_cidr
  instance_id = module.bastion-host.id
}


module "main_ecr" {
  source                = "./modules/ecr"
  aws_region            = var.region
  ecr_repository_name   = var.ecr_name
}


module "sg" {
  source = "./modules/sg"
  vpc_id = module.main_vpc.vpc_id
}


module "rds" {
  source = "./modules/rds"
  db_password = var.db_password
  sg_id = module.sg.rds_sg_id
  subnet_1_id = module.main_vpc.subnet_2_a_id
  subnet_2_id = module.main_vpc.subnet_2_b_id
}


module "bastion-host" {
  source = "./modules/ec2"
  subnet_id = module.main_vpc.public_subnet_bastion_id
  security_group_id = module.sg.bastion_sg_id
}


module "role" {
  source = "./modules/iam/role"
}


module "eks-cluster" {
  source = "./modules/eks"
  eks_cluster_sg_id = module.sg.eks_sg_id
  eks_subnet_1_id = module.main_vpc.subnet_1_a_id
  eks_subnet_2_id = module.main_vpc.subnet_1_b_id
  role_arn = module.role.eks_role_arn
}


module "s3" {
  source = "./modules/s3"
}