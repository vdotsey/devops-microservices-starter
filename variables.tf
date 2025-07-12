variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
}

# Add your variable declarations here

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = list(string)
}

variable "availability_zone" {
  description = "Availability zone for the subnets"
  type        = string 
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}
# Add your variable declarations below
# variable "eks_ingress_rule" {
#   type = map(object({
#     port        = number
#     cidr_blocks = list(string)
#     description = string
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


variable "key_name" {
  description = "SSH key name for EKS nodes"
  type        = string
}

variable "cluster_role_arn" {
  description = "IAM role ARN for the EKS cluster"
  type        = string
}

variable "node_role_arn" {
  description = "IAM role ARN for the EKS nodes"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

# variable "efs_ingress_rule" {
#   description = "Ingress rule for EFS"
#   type        = map(any)
# }

variable "efs_ingress_rule" {
  description = "List of ingress rules for the EFS security group"
  type = list(object({
    port            = number
    protocol        = string
    cidr_blocks     = list(string)
    security_group  = optional(list(string))
  }))
}



