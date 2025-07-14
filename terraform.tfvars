environment = "dev"
// Removed or replaced with a valid attribute name
cidr_block  = "10.0.0.0/16"
public_subnet_cidr = ["10.0.0.0/24", "10.0.1.0/24"]
availability_zone = "us-west-2a"
aws_region = "eu-north-1" 
key_name = "practice-key"
vpc_name = "dev-vpc"
node_role_arn = "arn:aws:iam::711387141889:role/EKSNodeRole"
cluster_role_arn = "arn:aws:iam::711387141889:role/EKSClusterRole"
efs_ingress_rule = [
  {
    port           = 2049
    protocol       = "tcp"
    cidr_blocks    = ["10.1.0.0/16"]
    security_group = null
  }
]
eks_ingress_rule = [
  {
    cidr_block = "0.0.0.0/0"
    protocol   = "tcp"
    from_port  = 443
    to_port    = 443
  },
  {
    cidr_block = "0.0.0.0/0"
    protocol   = "tcp"
    from_port  = 80
    to_port    = 80
  }
]

