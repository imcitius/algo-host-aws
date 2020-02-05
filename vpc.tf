resource "aws_vpc" "algo" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = "algo vpc"
  }
}

resource "aws_internet_gateway" "algo_gw" {
  vpc_id = aws_vpc.algo.id
}

resource "aws_subnet" "algo" {
  vpc_id     = aws_vpc.algo.id
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true

  depends_on = [
    aws_internet_gateway.algo_gw
  ]

  tags = {
    Name = "algo subnet"
  }
}

resource "aws_default_route_table" "route_table" {

  default_route_table_id = aws_vpc.algo.default_route_table_id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.algo_gw.id
  }
  
  tags = {
    Name = "algo route table"
  }

}
