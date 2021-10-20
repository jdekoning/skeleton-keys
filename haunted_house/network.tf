resource "aws_vpc" "boundary" {
  cidr_block                       = "10.0.0.0/16"
  assign_generated_ipv6_cidr_block = true
}

locals {
  az-subnet-mapping = [
    {
      name      = "subnet1"
      az        = "eu-west-1a"
      cidr      = cidrsubnet(aws_vpc.boundary.cidr_block, 8, 0)
      ipv6_cidr = cidrsubnet(aws_vpc.boundary.ipv6_cidr_block, 8, 0)
    },
    {
      name      = "subnet2"
      az        = "eu-west-1b"
      cidr      = cidrsubnet(aws_vpc.boundary.cidr_block, 8, 1)
      ipv6_cidr = cidrsubnet(aws_vpc.boundary.ipv6_cidr_block, 8, 1)
    },
  ]
}

resource "aws_subnet" "boundary" {
  count = length(local.az-subnet-mapping)

  cidr_block                      = lookup(local.az-subnet-mapping[count.index], "cidr")
  ipv6_cidr_block                 = lookup(local.az-subnet-mapping[count.index], "ipv6_cidr")
  vpc_id                          = aws_vpc.boundary.id
  assign_ipv6_address_on_creation = true
  map_public_ip_on_launch         = true
  availability_zone               = lookup(local.az-subnet-mapping[count.index], "az")
}

resource "aws_internet_gateway" "boundary" {
  vpc_id = aws_vpc.boundary.id
}

# Is this really needed?
resource "aws_default_route_table" "boundary" {
  default_route_table_id = aws_vpc.boundary.main_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.boundary.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.boundary.id
  }
}

resource "aws_route_table_association" "boundary" {
  count          = length(aws_subnet.boundary)
  subnet_id      = aws_subnet.boundary[count.index].id
  route_table_id = aws_default_route_table.boundary.id
}

resource "aws_security_group" "boundary-ssh" {
  name   = "boundary-ssh-access"
  vpc_id = aws_vpc.boundary.id
  ingress {
    description      = "Inbound SSH allowed"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "Inbound TLS allowed"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    description      = "Outbound all allowed"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
