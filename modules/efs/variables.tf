variable "efs_ingress_rule" {
    description = "List of ingress rules for the EFS security group"
    type = list(object({
        port         = number
        protocol     = string
        cidr_blocks  = list(string)
        security_group = optional(list(string))
    }))
  
}

variable "efs" {
    description = "EFS tags"
    type = map(string)
    default = {
        Name        = "eks-efs"
        Environment = "dev"
    }
}   

variable "vpc_id" {
    description = "The ID of the VPC where the EFS will be created"
    type        = string
}

variable "subnet_ids" {
    description = "List of subnet IDs for the EFS mount targets"
    type        = list(string)      
  
}
variable "sg" {
    description = "Security group tags"
    type = map(string)
    default = {
        Name        = "efs-SG"
        Environment = "dev"
    }
}