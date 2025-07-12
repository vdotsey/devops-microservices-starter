output "vpc_name" {
  description = "The name of the VPC"
  value = aws_vpc.dev_vpc.tags["Name"]
}
output "vpc_id" {
  description = "The ID of the VPC"
  value = aws_vpc.dev_vpc.id
}
output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value = aws_subnet.public_subnet[*].id
}
output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value = aws_internet_gateway.dev_igw.id
}

# output "private_subnet_ids" {
#   description = "List of private subnet IDs"
#   value = aws_subnet.private_subnet[*].id
# }

# output "nat_gateway_id" {
#   description = "The ID of the NAT Gateway"
#   value = aws_nat_gateway.dev.id
# }
# output "nat_eip_id" {
#   description = "The ID of the NAT EIP"
#   value = aws_eip.dev.id
# }
