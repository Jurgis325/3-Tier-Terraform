#Create VPC
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

#Create subnets
#Public Subnet
resource "aws_subnet" "Front" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Front"
  }
}
#Private Subnets
resource "aws_subnet" "Middle" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Middle"
  }
}

resource "aws_subnet" "Back" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = false

  tags = {
    Name = "Back"
  }
}

#Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main.id
}

#Route table
resource "aws_route_table" "route_table_public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}
#Route table association
resource "aws_route_table_association" "route_table_association_public" {
  subnet_id      = aws_subnet.Front.id
  route_table_id = aws_route_table.route_table_public.id
}

#elastic IP
resource "aws_eip" "nat_eip" {
  vpc        = true
}

#NAT gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.Front.id
}

#route table for middle subnet
resource "aws_route_table" "route_table_middle" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
}

resource "aws_route_table_association" "route_table_association_private" {
  subnet_id      = aws_subnet.Middle.id
  route_table_id = aws_route_table.route_table_middle.id
}