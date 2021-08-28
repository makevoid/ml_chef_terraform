resource "aws_security_group" "ec2-vms-sg-1" {
  description = "expose ssh and tensorflow state"

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

  name = "ec2-vms-sg-1"

  # TODO: configure and import vpc
  vpc_id = "vpc-8afcfce3"
}
