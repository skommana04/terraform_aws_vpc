resource "aws_vpc" "main" {
    cidr_block = var.cidr_block
    enable_dns_hostnames = true
    instance_tenancy = "default"

    tags = merge(
        var.vpc_tags,
        local.common_tags,
        {
        Name = "${local.comman_name_suffix}-vpc"
        }
   )
}
#-------------------------------------
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

    tags = merge(
        var.igw_tags,
        local.common_tags,
        {
        Name = "${local.comman_name_suffix}-igw"
        }
   )
}
#-----------------------------------

resource "aws_subnet" "public" {
  count = length(var.public_cidr_blocks)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_cidr_blocks[count.index]
 availability_zone = local.az_names[count.index]
  map_public_ip_on_launch = true
  
    tags = merge(
        var.public_subnet_tags,
        local.common_tags,
        {
        Name = "${local.comman_name_suffix}-public-${local.az_names[count.index]}"
        }
    )
}
resource "aws_subnet" "private" {
  count = length(var.private_cidr_blocks)
  vpc_id     = aws_vpc.main.id
    cidr_block = var.private_cidr_blocks[count.index]
  availability_zone = local.az_names[count.index]

    tags = merge(
        var.private_subnet_tags,
        local.common_tags,
        {
        Name = "${local.comman_name_suffix}-private-${local.az_names[count.index]}"
        }
   )
}
resource "aws_subnet" "database" {
    count = length(var.database_cidr_blocks)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_cidr_blocks[count.index]
 availability_zone = local.az_names[count.index] 

    tags = merge(
        var.database_subnet_tags,
        local.common_tags,
        {
        Name = "${local.comman_name_suffix}-database-${local.az_names[count.index]}"
        }
   )
}
#----------------------------------------

resource "aws_route_table" "rt_public" {
  vpc_id     = aws_vpc.main.id  
    tags = merge(
        var.public_routetable_tags,
        local.common_tags,
        {
        Name = "${local.comman_name_suffix}-public-routetable"
        }
    )
}
resource "aws_route_table" "rt_private" {
  vpc_id     = aws_vpc.main.id  
    tags = merge(
        var.private_routetable_tags,
        local.common_tags,
        {
        Name = "${local.comman_name_suffix}-private-routetable"
        }
    )
}
resource "aws_route_table" "rt_database" {
  vpc_id     = aws_vpc.main.id  
    tags = merge(
        var.database_routetable_tags,
        local.common_tags,
        {
        Name = "${local.comman_name_suffix}-database-routetable"
        }
    )
}
#--------------------------------------------------

resource "aws_route_table_association" "rta_public" {
  count = length(var.public_cidr_blocks)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.rt_public.id
}

resource "aws_route_table_association" "rta_private" {
  count = length(var.private_cidr_blocks)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.rt_private.id
}

resource "aws_route_table_association" "rta_database" {
  count = length(var.database_cidr_blocks)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.rt_database.id
}
#---------------------------------------------
resource "aws_eip" "lb" {
  domain   = "vpc"
      tags = merge(
        var.eip_tags,
        local.common_tags,
        {
        Name = "${local.comman_name_suffix}-eip"
        }
    )
}
#---------------------------------------
resource "aws_nat_gateway" "example" {
  allocation_id = aws_eip.lb.id
  subnet_id     = aws_subnet.public[0].id
  tags = merge(
    var.nat_tags,
    local.common_tags,
    {
    Name = "${local.comman_name_suffix}-nat"
    }
)

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}
#-------------------------------------------------
resource "aws_route" "r_public" {
  route_table_id            = aws_route_table.rt_public.id
  gateway_id = aws_internet_gateway.gw.id
  destination_cidr_block = "0.0.0.0/0"

}

resource "aws_route" "r_private" {
  route_table_id            = aws_route_table.rt_private.id
  nat_gateway_id = aws_nat_gateway.example.id
  destination_cidr_block = "0.0.0.0/0"
  

}
resource "aws_route" "r_database" {
  route_table_id            = aws_route_table.rt_database.id
  nat_gateway_id = aws_nat_gateway.example.id
  destination_cidr_block = "0.0.0.0/0"

}
#----------------------------------------