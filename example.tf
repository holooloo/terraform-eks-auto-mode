locals {
  cluster_name = "infra"
  eks_version  = "1.32"
  vpc_cidr     = "10.10.0.0/16"
  subnets_public = {
    "subnet-1" = { cidr_block = "10.10.0.0/21", availability_zone = "eu-central-1a" }
    "subnet-2" = { cidr_block = "10.10.8.0/21", availability_zone = "eu-central-1b" }
  }
  subnets_private = {
    "subnet-1" = { cidr_block = "10.10.16.0/21", availability_zone = "eu-central-1a" }
    "subnet-2" = { cidr_block = "10.10.24.0/21", availability_zone = "eu-central-1b" }
  }
  eks_admins = {
    "holooloo" = { arn = "arn:aws:iam::xxxxxx:user/holooloo", access_type = "cluster" }
  }


###
# EKS
###

module "eks" {
  source       = "../../../modules/eks"
  cluster_name = local.cluster_name
  eks_version  = local.eks_version
  subnets      = module.vpc.private_subnets # Needs subnets IDs
}

resource "aws_eks_access_entry" "this" {
  for_each      = local.eks_admins
  cluster_name  = local.cluster_name
  principal_arn = each.value.arn
  type          = "STANDARD"

  depends_on = [module.eks]
}

resource "aws_eks_access_policy_association" "this" {
  for_each      = local.eks_admins
  cluster_name  = local.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = each.value.arn
  access_scope {
    type = each.value.access_type
  }

  depends_on = [module.eks]
}

