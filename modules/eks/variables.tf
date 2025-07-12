variable "environment" {
  description = "The environment for the EKS cluster (e.g., dev, prod)"
  type        = string
}

variable "node_group_desired_size" {
  description = "The desired number of nodes in the EKS node group"
  type        = number
  default     = 2
}
variable "node_group_max_size" {
  description = "The maximum number of nodes in the EKS node group"
  type        = number
  default     = 3
}
variable "node_group_min_size" {
  description = "The minimum number of nodes in the EKS node group"
  type        = number
  default     = 1
}

variable "eks_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = "eks-cluster"
}
variable "vpc_id" {
  description = "The ID of the VPC where the EKS cluster will be created"
  type        = string
}
variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster"
  type        = list(string)
}
variable "cluster_role_arn" {
  description = "The ARN of the IAM role for the EKS cluster"
  type        = string
}
variable "node_role_arn" {
  description = "The ARN of the IAM role for the EKS node group"
  type        = string
}

variable "sescurity_group" {
  description = "The security group for the EKS cluster"
  type        = map(string)
  default     = {
    Name        = "eks-cluster-sg"
    Description = "EKS Cluster Security Group"
  }
}
variable "node_name" {
  description = "The name of the EKS node group"
  type        = string
  default     = "eks-node-group"
}

# variable "eks_ingress_rule" {
#   type = map(object({
#     port         = number
#     protocol     = string
#     cidr_block   = list(string)
#     description  = string
#   }))
# }

variable "eks_ingress_rule" {
  description = "List of ingress rules for EKS"
  type = list(object({
    cidr_block = string
    protocol   = string
    from_port  = number
    to_port    = number
  }))
}


variable "ssh_key_name" {
  description = "The name of the SSH key pair to use for accessing the EKS nodes"
  type        = string
}
variable "eks_node_policies" {
  default = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess",
    "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy",
    "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess",
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  ]
  
}


variable "eks_cluster_policies" {
  default = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSBlockStoragePolicy",
    "arn:aws:iam::aws:policy/AmazonEKSComputePolicy",
    "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSNetworkingPolicy"
  ]
}

