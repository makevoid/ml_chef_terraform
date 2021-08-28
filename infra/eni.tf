# resource "aws_network_interface" "ec2-vm-1-eni" {
#   attachment {
#     device_index = "0"
#     instance     = aws_instance.ec2-vm-1.id
#   }
#
#   # interface_type     = "interface"
#   ipv6_address_count = "0"
#   security_groups    = [aws_security_group.ec2-vms-nsg-1.id]
#   source_dest_check  = "true"
#   subnet_id          = aws_subnet.default_subnet.id
# }
