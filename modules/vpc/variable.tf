variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}

variable "aws_region" {
  description = "The AWS region where the VPC will be created"
  type        = string
}

variable "cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "The CIDR block for the public subnet"
  type        = list(string)
}

variable "availability_zone" {
  description = "The availability zone for the subnets"
  type        = string
}

variable "subnet_count" {
  description = "The number of subnets to create"
  type        = number
  default     = 2  
}

