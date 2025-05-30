resource "aws_security_group" "jenkins_sg" {
  name        = var.sg_name
  description = var.sg_description
  vpc_id      = aws_vpc.jenkins_vpc.id

  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = var.tcp_protocol
    cidr_blocks = var.cidr_blocks
  }

  ingress {
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = var.tcp_protocol
    cidr_blocks = var.cidr_blocks
  }

  egress {
    from_port   = var.egress_from_port
    to_port     = var.egress_to_port
    protocol    = var.egress_protocol
    cidr_blocks = var.egress_cidr_blocks
  }


  tags = {
    Name = var.sg_name
  }
}
