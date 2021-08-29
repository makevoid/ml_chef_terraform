output "vm_1_public_ip" {
  value = aws_instance.ec2-vm-1.public_ip
}

resource "local_file" "vm_1_public_ip" {
  content  = aws_instance.ec2-vm-1.public_ip
  filename = "outputs/vm_1_public_ip.txt"
}
