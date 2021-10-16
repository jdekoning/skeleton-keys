resource "tls_private_key" "boundary" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.boundary_key_name
  public_key = tls_private_key.boundary.public_key_openssh

  tags = {
    creator = "terraform"
    goal    = "haunted_house"
  }
}

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
  availability_zone               = lookup(local.az-subnet-mapping[count.index], "az")

  tags = {
    Name    = lookup(local.az-subnet-mapping[count.index], "name")
    creator = "terraform"
    goal    = "haunted_house"
  }
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

resource "aws_instance" "boundary_controller" {
  ami                = data.aws_ami.ubuntu.image_id
  key_name           = aws_key_pair.generated_key.key_name
  instance_type      = "t2.micro"
  subnet_id          = aws_subnet.boundary[0].id
  ipv6_address_count = 1
  #  vpc_security_group_ids = ["${aws_security_group.eu-central-1.id}"]
  tags = {
    creator = "terraform"
    goal    = "haunted_house"
  }
  depends_on = [aws_internet_gateway.boundary]
}


