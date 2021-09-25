resource "aws_security_group" "ec2-vms-nsg-1" {
  description = "Open SSH and Tensorflow monitoring ports"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    protocol    = "-1"
    self        = "false"
    to_port     = "0"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "22"
    protocol    = "tcp"
    self        = "false"
    to_port     = "22"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "6060"
    protocol    = "tcp"
    self        = "false"
    to_port     = "6060"
  }

  #name   = "ec2-vms-nsg-1"
  vpc_id = "vpc-027327d44a2e85766"
}
