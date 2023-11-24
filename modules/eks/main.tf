resource "aws_eks_cluster" "hanggi-eks-cluster" {
  name     = "hanggi-eks-cluster"
  role_arn = var.role_arn
  version = "1.28"

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  vpc_config {
    security_group_ids = [ var.eks_cluster_sg_id ]
    subnet_ids         = [ var.eks_subnet_1_id, var.eks_subnet_2_id ]
    endpoint_private_access = true
    endpoint_public_access = true
  }
}


resource "aws_eks_node_group" "eks-nodes" {
  cluster_name  = aws_eks_cluster.hanggi-eks-cluster.name
  node_group_name = "eks-nodes"
  node_role_arn = var.role_arn
  subnet_ids    = [ var.eks_subnet_1_id, var.eks_subnet_2_id ]
  instance_types = [ "t3.small" ]
  disk_size = 20
  ami_type = "AL2_x86_64"

  scaling_config {
    desired_size = 3
    max_size     = 4
    min_size     = 2
  }
}
