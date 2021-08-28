resource "aws_network_interface" "tfer--eni-002D-0cefa9ffb217d880c" {
  attachment {
    device_index = "0"
    instance     = "i-0e063c9c4d73951bb"
  }

  interface_type     = "interface"
  ipv6_address_count = "0"
  private_ip         = "172.31.20.45"
  private_ips        = ["172.31.20.45"]
  private_ips_count  = "0"
  security_groups    = ["sg-0d802d7deebd48786"]
  source_dest_check  = "true"
  subnet_id          = "subnet-86d7d9fd"
}
