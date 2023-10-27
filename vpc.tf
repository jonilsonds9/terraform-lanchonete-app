# data "aws_availability_zones" "available" {}

# module "vpc" {
#   source  = "terraform-aws-modules/vpc/aws"
#   version = "5.1.2"

#   name    = "vpc-lanchonete"
#   cidr    = "10.0.0.0/16"

#   azs             = ["us-east-2a", "us-east-2b", "us-east-2c"]
#   private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
#   public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

#   enable_nat_gateway = true

#   tags = local.tags
# }



resource "aws_vpc" "this" {
  cidr_block           = "192.168.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.tags, { Name : "lanchonete-app-VPC" })
}

resource "aws_internet_gateway" "this" {
  vpc_id = vpc.this.id
  tags = merge(local.tags, { Name : "lanchonete-app-IGW" })
}

resource "aws_subnet" "this" {
  for_each = {
    "pub_a" : ["192.168.1.0/24", "${var.aws_region}a", "Public A"]
    "pub_b" : ["192.168.2.0/24", "${var.aws_region}b", "Public B"]
  }

  vpc_id            = vpc.this.id
  cidr_block        = each.value[0]
  availability_zone = each.value[1]

  tags = merge(local.tags, { Name = each.value[2] })
}

resource "aws_route_table" "public" {
  vpc_id = vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(local.tags, { Name : "lanchonete-app-PUBILC" })
}

resource "aws_route_table_association" "this" {
  for_each = local.subnet_ids

  subnet_id      = each.value
  route_table_id = aws_route_table.public.id
}