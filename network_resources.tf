# Creating VPC
resource "aws_vpc" "new_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "terraform"
  }
}

# Creating Subnet1
resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.new_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.new_vpc.cidr_block, 8, 1)
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1a"

  tags = {
    name = "terraform subnet 1"
  }

}

# Creating Subnet2
resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.new_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.new_vpc.cidr_block, 8, 2)
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1b"

  tags = {
    name = "terraform subnet 2"
  }

}

# Creating IGW
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.new_vpc.id

  tags = {
    Name = "terraform_igw"
  }

}

# Creating RT
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.new_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "terraform_route_table"
  }

}

# Associate RT with relevant Subnets
resource "aws_route_table_association" "subnet1_route" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "subnet2_route" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.route_table.id
}

# Create SG with ingress/egress 
resource "aws_security_group" "security_group" {
  name   = "ecs-security-group"
  vpc_id = aws_vpc.new_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    self        = "false"
    cidr_blocks = ["0.0.0.0/0"]
    description = "any"
  }

    ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    self        = "false"
    cidr_blocks = ["0.0.0.0/0"]
    description = "any"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
