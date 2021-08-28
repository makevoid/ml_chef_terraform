provider "aws" {
  region = "eu-central-1"
}

resource "aws_vpc" "vpc_default" {
  # id         = "vpc-8afcfce3"
  cidr_block = "172.31.0.0/16"
  tags = {
    "Name" = "Training Budget VPC 1"
  }
}
