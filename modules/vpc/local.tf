locals {
  public_subnet_ids = [for subnet in aws_subnet.public_subnet : subnet.id ]
  common_tags = {
    Project        = "eks"
    Environment = "dev"
  }
  name_prefix = "${local.common_tags.Project}-${local.common_tags.Environment}"
}