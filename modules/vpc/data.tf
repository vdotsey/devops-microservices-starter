data "aws_availability_zones" "azs" {
  state = "available"
}
locals {
  azs = data.aws_availability_zones.azs.names
  subnet_ids = [for subnet in aws_subnet.public_subnet : subnet.id ]
}
