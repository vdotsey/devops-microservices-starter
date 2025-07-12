locals {
  common_tags = {
    Project     = "eks"
    Environment = "dev"
  }

  name_prefix = "${local.common_tags.Project}-${local.common_tags.Environment}"
}