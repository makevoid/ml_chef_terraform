resource "aws_subnet" "ec2-vms-subnet-1" {
  assign_ipv6_address_on_creation = "false"
  cidr_block                      = "172.31.0.0/20" # TODO: store in confi / tfvars bump programmatically
  # map_customer_owned_ip_on_launch = "false"
  map_public_ip_on_launch = "true"

  # TODO: cleanup
  vpc_id = aws_vpc.vpc_default.id
  # vpc_id = "vpc-8afcfce3"
  # vpc_id = data.terraform_remote_state.vpc.outputs.aws_vpc_tfer--vpc-002D-8afcfce3_id
}
