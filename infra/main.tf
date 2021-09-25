provider "aws" {
  # region  = "eu-central-1"
  region  = "eu-west-1"
  profile = "makevoid"
}

resource "aws_vpc" "vpc_default" {
  cidr_block = "172.31.0.0/16"
  tags = {
    "Name" = "Training Budget VPC 1"
  }
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_subnet" "default_subnet" {
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
