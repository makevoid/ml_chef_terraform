resource "aws_subnet" "tfer--subnet-002D-86d7d9fd" {
  assign_ipv6_address_on_creation = "false"
  cidr_block                      = "172.31.16.0/20"
  map_customer_owned_ip_on_launch = "false"
  map_public_ip_on_launch         = "true"
  vpc_id                          = "${data.terraform_remote_state.vpc.outputs.aws_vpc_tfer--vpc-002D-8afcfce3_id}"
}

resource "aws_subnet" "tfer--subnet-002D-c50b388f" {
  assign_ipv6_address_on_creation = "false"
  cidr_block                      = "172.31.32.0/20"
  map_customer_owned_ip_on_launch = "false"
  map_public_ip_on_launch         = "true"
  vpc_id                          = "${data.terraform_remote_state.vpc.outputs.aws_vpc_tfer--vpc-002D-8afcfce3_id}"
}

resource "aws_subnet" "tfer--subnet-002D-dd1be7b5" {
  assign_ipv6_address_on_creation = "false"
  cidr_block                      = "172.31.0.0/20"
  map_customer_owned_ip_on_launch = "false"
  map_public_ip_on_launch         = "true"
  vpc_id                          = "${data.terraform_remote_state.vpc.outputs.aws_vpc_tfer--vpc-002D-8afcfce3_id}"
}
