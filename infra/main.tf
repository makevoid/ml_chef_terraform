provider "aws" {
  region = "eu-central-1"
}

resource "aws_vpc" "vpc_default" {
  # id         = "vpc-8afcfce3"
  cidr_block = "172.31.0.0/16"
  tags = {
    "Name" = "Training Budget VPC 1"
  }
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_subnet" "default_subnet" {
  #id         = "subnet-dd1be7b5"
  cidr_block              = "172.31.0.0/20"
  vpc_id                  = aws_vpc.vpc_default.id
  map_public_ip_on_launch = true
  tags = {
    "Name" = "default-subnet-0"
  }
  lifecycle {
    prevent_destroy = true
  }
}

# data "aws_subnet_ids" "default_subnet_ids" {
#   vpc_id = aws_vpc.vpc_default.id
# }
#
# data "aws_subnet" "default_subnet" {
#   id = tolist(data.aws_subnet_ids.default_subnet_ids.ids)[0]
# }
#
# output "default_subnet_id" {
#   value = data.aws_subnet.default_subnet.id
# }
#
# resource "aws_subnet" "subnet_default" {
#   vpc_id     = aws_vpc.vpc_default.id
#   id         = data.aws_subnet.default_subnet.id
#   cidr_block = "172.31.0.0/20"
# }
