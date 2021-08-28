resource "aws_internet_gateway" "tfer--igw-002D-fa026393" {
  vpc_id = "${data.terraform_remote_state.vpc.outputs.aws_vpc_tfer--vpc-002D-8afcfce3_id}"
}
