resource "aws_vpc" "tfer--vpc-002D-8afcfce3" {
  assign_generated_ipv6_cidr_block = "false"
  cidr_block                       = "172.31.0.0/16"
  enable_dns_hostnames             = "true"
  enable_dns_support               = "true"
  instance_tenancy                 = "default"

  tags = {
    Name = "Training Budget VPC 1"
  }

  tags_all = {
    Name = "Training Budget VPC 1"
  }
}
