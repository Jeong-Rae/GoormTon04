resource "aws_vpc" "goorm-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "GoormVpc"
  }
}

# 공개 서브넷 a :web
resource "aws_subnet" "web-public-subnet-a" {
  vpc_id            = aws_vpc.goorm-vpc.id
  cidr_block        = "10.0.0.0/20"
  availability_zone = "ap-northeast-2a"
  map_public_ip_on_launch = true


  tags = {
    Name = "WebPublicSubnetA"
  }
}

# 공개 서브넷 c :web
resource "aws_subnet" "web-public-subnet-c" {
  vpc_id            = aws_vpc.goorm-vpc.id
  cidr_block        = "10.0.16.0/20"
  availability_zone = "ap-northeast-2c"
  map_public_ip_on_launch = true


  tags = {
    Name = "WebPublicSubnetC"
  }
}

# 비공개 서브넷 a :app
resource "aws_subnet" "app-private-subnet-a" {
  vpc_id            = aws_vpc.goorm-vpc.id
  cidr_block        = "10.0.128.0/20"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "AppPrivateSubnetA"
  }
}

# 비공개 서브넷 c :app
resource "aws_subnet" "app-private-subnet-c" {
  vpc_id            = aws_vpc.goorm-vpc.id
  cidr_block        = "10.0.144.0/20"
  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "AppPrivateSubnetC"
  }
}

# 비공개 서브넷 a :db
resource "aws_subnet" "db-private-subnet-a" {
  vpc_id            = aws_vpc.goorm-vpc.id
  cidr_block        = "10.0.160.0/20"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "DBPrivateSubnetA"
  }
}

# 비공개 서브넷 c :db
resource "aws_subnet" "db-private-subnet-c" {
  vpc_id            = aws_vpc.goorm-vpc.id
  cidr_block        = "10.0.176.0/20"
  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "DBPrivateSubnetC"
  }
}

# IGW
resource "aws_internet_gateway" "goorm-igw" {
  vpc_id = aws_vpc.goorm-vpc.id

  tags = {
    Name = "GoormIGW"
  }
}

# NAT
resource "aws_eip" "goorm-nat-eip" {
	domain = "vpc"
}

resource "aws_nat_gateway" "goorm-nat-gateway" {
  allocation_id = aws_eip.goorm-nat-eip.id
  subnet_id     = aws_subnet.web-public-subnet-a.id

  tags = {
    Name = "GoormNatGateway"
  }
}

# Web Route Table 설정
resource "aws_route_table" "web-route-table" {
  vpc_id = aws_vpc.goorm-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.goorm-igw.id
  }

  tags = {
    Name = "WebRouteTable"
  }
}

resource "aws_route_table_association" "web-route-table-association-a" {
  subnet_id      = aws_subnet.web-public-subnet-a.id
  route_table_id = aws_route_table.web-route-table.id
}

resource "aws_route_table_association" "web-route-table-association-c" {
  subnet_id      = aws_subnet.web-public-subnet-c.id
  route_table_id = aws_route_table.web-route-table.id
}

# App Route Table 설정
resource "aws_route_table" "app-route-table" {
  vpc_id = aws_vpc.goorm-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.goorm-nat-gateway.id
  }

  tags = {
    Name = "AppRouteTable"
  }
}

resource "aws_route_table_association" "app-route-table_association_a" {
  subnet_id      = aws_subnet.app-private-subnet-a.id
  route_table_id = aws_route_table.app-route-table.id
}

resource "aws_route_table_association" "app-route-table_association_c" {
  subnet_id      = aws_subnet.app-private-subnet-c.id
  route_table_id = aws_route_table.app-route-table.id
}

# DB Route Table 설정
resource "aws_route_table" "db-route-table" {
  vpc_id = aws_vpc.goorm-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.goorm-nat-gateway.id
  }

  tags = {
    Name = "DBRouteTable"
  }
}

resource "aws_route_table_association" "db-route-table_association_a" {
  subnet_id      = aws_subnet.db-private-subnet-a.id
  route_table_id = aws_route_table.db-route-table.id
}

resource "aws_route_table_association" "db-route-table_association_c" {
  subnet_id      = aws_subnet.db-private-subnet-c.id
  route_table_id = aws_route_table.db-route-table.id
}
