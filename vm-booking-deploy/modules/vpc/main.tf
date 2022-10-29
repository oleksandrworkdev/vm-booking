data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  tags = {
    CreatedBy = var.vpc_created_by
    Name      = var.vpc_name
  }
}

resource "aws_subnet" "public_az" {
  count = 2

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, var.vpc_subnet_newbits, count.index)
  map_public_ip_on_launch = true
  depends_on              = [aws_internet_gateway.igw]

  tags = merge(var.public_subnet_tags, {
    CreatedBy = var.vpc_created_by
    Name      = "${var.vpc_name}-public-subnet-${count.index + 1}"
  })
}

resource "aws_subnet" "private_az" {
  count = 2

  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, var.vpc_subnet_newbits, 2 + count.index)

  tags = merge(var.private_subnet_tags, {
    CreatedBy = var.vpc_created_by
    Name      = "${var.vpc_name}-private-subnet-${count.index + 1}"
  })
}

resource "aws_eip" "nat_eip_1" {
  vpc        = true
  depends_on = [aws_internet_gateway.igw]

  tags = {
    CreatedBy = var.vpc_created_by
    Name      = "${var.vpc_name}-nat-eip-1"
  }
}

resource "aws_eip" "nat_eip_2" {
  vpc        = true
  depends_on = [aws_internet_gateway.igw]

  tags = {
    CreatedBy = var.vpc_created_by
    Name      = "${var.vpc_name}-nat-eip-2"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    CreatedBy = var.vpc_created_by
    Name      = "${var.vpc_name}-igw"
  }
}

resource "aws_nat_gateway" "nat_igw_1" {
  allocation_id = aws_eip.nat_eip_1.id
  subnet_id     = aws_subnet.public_az[0].id

  depends_on = [aws_internet_gateway.igw]

  tags = {
    CreatedBy = var.vpc_created_by
    Name      = "${var.vpc_name}-nat-igw-1"
  }
}

resource "aws_nat_gateway" "nat_igw_2" {
  allocation_id = aws_eip.nat_eip_2.id
  subnet_id     = aws_subnet.public_az[1].id

  depends_on = [aws_internet_gateway.igw]

  tags = {
    CreatedBy = var.vpc_created_by
    Name      = "${var.vpc_name}-nat-igw-2"
  }
}

# Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    CreatedBy = var.vpc_created_by
    Name      = "${var.vpc_name}-public-rt"
  }
}

resource "aws_route_table_association" "public_rt_association_1" {
  subnet_id      = aws_subnet.public_az[0].id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_association_2" {
  subnet_id      = aws_subnet.public_az[1].id
  route_table_id = aws_route_table.public_rt.id
}

# Private Route Table
resource "aws_route_table" "private_rt_1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_igw_1.id
  }

  tags = {
    CreatedBy = var.vpc_created_by
    Name      = "${var.vpc_name}-private-rt-1"
  }
}

resource "aws_route_table_association" "private_rt_association_1" {
  subnet_id      = aws_subnet.private_az[0].id
  route_table_id = aws_route_table.private_rt_1.id
}

resource "aws_route_table" "private_rt_2" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_igw_2.id
  }

  tags = {
    CreatedBy = var.vpc_created_by
    Name      = "${var.vpc_name}-private-rt-2"
  }
}

resource "aws_route_table_association" "private_rt_association_2" {
  subnet_id      = aws_subnet.private_az[1].id
  route_table_id = aws_route_table.private_rt_2.id
}

resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id          = aws_vpc.main.id
  service_name    = "com.amazonaws.${data.aws_region.current.name}.s3"
  route_table_ids = [aws_route_table.public_rt.id, aws_route_table.private_rt_1.id, aws_route_table.private_rt_2.id]

  tags = {
    CreatedBy = var.vpc_created_by
    Name      = "${var.vpc_name}-s3-endpoint"
  }
}

resource "aws_vpc_endpoint" "dynamodb_endpoint" {
  vpc_id          = aws_vpc.main.id
  service_name    = "com.amazonaws.${data.aws_region.current.name}.dynamodb"
  route_table_ids = [aws_route_table.public_rt.id, aws_route_table.private_rt_1.id, aws_route_table.private_rt_2.id]

  tags = {
    CreatedBy = var.vpc_created_by
    Name      = "${var.vpc_name}-dynamodb-endpoint"
  }
}
