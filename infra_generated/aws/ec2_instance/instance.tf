resource "aws_instance" "ec2-vm-1" {
  ami                         = "ami-0c4b99db370d5fd24"
  associate_public_ip_address = "false"
  availability_zone           = "eu-central-1b"

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
  private_ip = "172.31.20.45"

  root_block_device {
    delete_on_termination = "true"
    encrypted             = "false"
    iops                  = "900"
    throughput            = "0"
    volume_size           = "300"
    volume_type           = "gp2"
  }

  security_groups        = ["launch-wizard-1"]
  source_dest_check      = "true"
  subnet_id              = "${data.terraform_remote_state.subnet.outputs.ec2-vms-subnet-1}"
  tenancy                = "default"
  vpc_security_group_ids = ["${data.terraform_remote_state.sg.outputs.aws_security_group_ec2-vms-sg-1}"]
}
