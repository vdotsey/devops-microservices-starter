resource "aws_vpc" "dev_vpc" {
    cidr_block = var.cidr_block
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = merge(
        local.common_tags,
        {
            Name = "${local.name_prefix}-vpc"
        }
    )

    }


resource "aws_internet_gateway" "dev_igw" {
    vpc_id = aws_vpc.dev_vpc.id
    tags = merge(
        local.common_tags,
        {
            Name = "${local.name_prefix}-igw"
        }
    )
}


resource "aws_subnet" "public_subnet" {
    count = 2
    vpc_id = aws_vpc.dev_vpc.id
    cidr_block = var.public_subnet_cidr[count.index]
    availability_zone = local.azs[count.index]    
    map_public_ip_on_launch = true
    tags = merge(
        local.common_tags,
        {
            Name = "${local.name_prefix}-public-subnet-${count.index + 1}"
        }
    )
}

resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.dev_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.dev_igw.id
    }
    tags = merge(
        local.common_tags,
        {
            Name = "${local.name_prefix}-public-route-table"
        }
    )
}

resource "aws_route_table_association" "public_subnet_association" {
    count = 2
    subnet_id = aws_subnet.public_subnet[count.index].id
    route_table_id = aws_route_table.public_route_table.id
}  

# resource "aws_subnet" "private_subnet" {
#     count = 2
#     vpc_id = aws_vpc.dev_vpc.id
#     cidr_block = var.private_subnet_cidr
#     availability_zone = local.azs[count.index] 
#     tags = merge(
#         local.common_tags,
#         {
#             Name = "${local.name_prefix}-private-subnet-${count.index + 1}"
#         }
#     )
# }


# resource "aws_route_table" "private_route_table" {
#     vpc_id = aws_vpc.dev_vpc.id
#     tags = merge(
#         local.common_tags,
#         {
#             Name = "${local.name_prefix}-private-route-table"
#         }
#     )
# }
# resource "aws_route_table_association" "dev_private" {
#     subnet_id = aws_subnet.private_subnet.id
#     route_table_id = aws_route_table.private_route_table.id
# }

# resource "aws_nat_gateway" "dev" {
#     allocation_id = aws_eip.dev.id
#     subnet_id = aws_subnet.public_subnet.id
#     tags = local.common_tags
# }
# resource "aws_eip" "dev" {
#     tags = merge(
#         local.common_tags,
#         {
#             Name = "${local.name_prefix}-nat-eip"
#         }
#     )
# }




