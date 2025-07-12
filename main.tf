# Reference existing IAM roles created manually
data "aws_iam_role" "cluster_role" {
  name = "eksClusterRole"  # Replace with your actual EKS cluster role name
}

data "aws_iam_role" "node_role" {
  name = "eksNodeRole"  # Replace with your actual EKS node group role name
}


module "vpc" {
  source = "./modules/vpc"

  aws_region          = var.aws_region
  cidr_block          = var.cidr_block
  availability_zone   = var.availability_zone
  vpc_name            = var.vpc_name
  public_subnet_cidr  = var.public_subnet_cidr
}

module "eks" {
  source = "./modules/eks"

  cluster_role_arn = data.aws_iam_role.cluster_role.arn
  node_role_arn = data.aws_iam_role.node_role.arn
  environment = var.environment
  subnet_ids = module.vpc.public_subnet_ids
  eks_ingress_rule = var.eks_ingress_rule
  vpc_id = module.vpc.vpc_id
  ssh_key_name = var.key_name
}

module "route53" {
  source = "./modules/route53"
}

module "ecr" {
    source = "./modules/ecr"
}

module "efs" {
  source = "./modules/efs"

  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnet_ids
  efs_ingress_rule = var.efs_ingress_rule
}

module "iam" {
  source = "./modules/iam"
}