resource "aws_instance" "ec2-vm-1" {
  # Ubuntu 18 AWS ML AMI 
  ami                         = "ami-0c4b99db370d5fd24"
  availability_zone           = "eu-central-1a"
  associate_public_ip_address = "true"

  capacity_reservation_specification {
    capacity_reservation_preference = "open"
  }

  cpu_core_count          = "4"
  cpu_threads_per_core    = "2"
  disable_api_termination = "false"
  ebs_optimized           = "true"

  enclave_options {
    enabled = "false"
  }

  get_password_data                    = "false"
  hibernation                          = "false"
  instance_initiated_shutdown_behavior = "stop"
  instance_type                        = "p3.2xlarge"
  ipv6_address_count                   = "0"
  key_name                             = "makevoid"

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = "1"
    http_tokens                 = "optional"
  }

  monitoring = "false"

  root_block_device {
    delete_on_termination = "true"
    encrypted             = "false"
    throughput            = "0"
    volume_size           = "300"
    volume_type           = "gp2"
    # iops                  = "900"
  }

  source_dest_check      = "true"
  subnet_id              = aws_subnet.default_subnet.id
  tenancy                = "default"
  vpc_security_group_ids = [aws_security_group.ec2-vms-nsg-1.id]
  # security_groups        = ["ec2-vms-nsg-1"]

  # aws_security_group.env-01-sg-bas.id
}
