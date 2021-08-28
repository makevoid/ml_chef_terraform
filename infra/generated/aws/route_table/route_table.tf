resource "aws_route_table" "tfer--rtb-002D-65918a0c" {
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "igw-fa026393"
  }

  vpc_id = "${data.terraform_remote_state.vpc.outputs.aws_vpc_tfer--vpc-002D-8afcfce3_id}"
}
