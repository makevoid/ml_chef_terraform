output "vm_1_public_ip" {
  value = aws_instance.env-01-vm-bas.public_ip


resource "local_file" "bastion_public_ip_output" {
  content  = aws_instance.env-01-vm-bas.public_ip
  filename = "output_bastion_public_ip.txt"
}
