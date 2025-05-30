resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "jenkins_key" {
  key_name   = "terraform-jenkins-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "local_file" "private_key_pem" {
  filename        = "${path.module}/terraform-jenkins-key.pem"
  content         = tls_private_key.ssh_key.private_key_pem
  file_permission = "0600"
}
