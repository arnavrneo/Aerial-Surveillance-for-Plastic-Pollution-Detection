# vpc creation
resource "aws_vpc" "tf-cluster-vpc" {
  cidr_block = "10.0.0.0/16"


  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Env  = "staging"
    Name = var.vpc_name
  }
}

# igw creation
resource "aws_internet_gateway" "tf-cluster-igw" {
  vpc_id = aws_vpc.tf-cluster-vpc.id

  tags = {
    Name = var.igw_name
  }
}

# subnet creation
resource "aws_subnet" "private-us-east-1a" {
  vpc_id            = aws_vpc.tf-cluster-vpc.id
  cidr_block        = "10.0.0.0/19"
  availability_zone = "us-east-1a"

  tags = {
    "Name"                                      = "private-us-east-1a"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_subnet" "private-us-east-1b" {
  vpc_id            = aws_vpc.tf-cluster-vpc.id
  cidr_block        = "10.0.32.0/19"
  availability_zone = "us-east-1b"

  tags = {
    "Name"                                      = "private-us-east-1b"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}


resource "aws_subnet" "public-us-east-1a" {
  vpc_id                  = aws_vpc.tf-cluster-vpc.id
  cidr_block              = "10.0.64.0/19"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    "Name"                                      = "public-us-east-1a"
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_subnet" "public-us-east-1b" {
  vpc_id                  = aws_vpc.tf-cluster-vpc.id
  cidr_block              = "10.0.96.0/19"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    "Name"                                      = "public-us-east-1b"
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

# nat-gw creation
## attach eip with nat-gw
resource "aws_eip" "tf-server-nat" {
  domain = "vpc"

  tags = {
    Name = var.natgw_name
  }
}

## nat-gw
resource "aws_nat_gateway" "tf-server-nat" {
  allocation_id = aws_eip.tf-server-nat.id
  subnet_id     = aws_subnet.public-us-east-1a.id

  tags = {
    Name = var.natgw_name
  }

  depends_on = [aws_internet_gateway.tf-cluster-igw]
}

# route tables creation
## private subnet to nat
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.tf-cluster-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.tf-server-nat.id
  }

  tags = {
    Name = var.private_rt_name
  }
}

## public subnet to igw
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.tf-cluster-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf-cluster-igw.id
  }

  tags = {
    Name = var.public_rt_name
  }
}

## associate rts above with subnet
resource "aws_route_table_association" "private-us-east-1a" {
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private-us-east-1a.id
}

resource "aws_route_table_association" "private-us-east-1b" {
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private-us-east-1b.id
}

resource "aws_route_table_association" "public-us-east-1a" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public-us-east-1a.id
}

resource "aws_route_table_association" "public-us-east-1b" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public-us-east-1b.id
}

