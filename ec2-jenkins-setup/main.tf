terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "jenkins_vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "jenkins-vpc"
  }
}

resource "aws_subnet" "jenkins_subnet" {
  vpc_id     = aws_vpc.jenkins_vpc.id
  cidr_block = "172.16.10.0/24"

  tags = {
    Name = "jenkins-subnet"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.jenkins_vpc.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.jenkins_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_subnet_assoc" {
  subnet_id      = aws_subnet.jenkins_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow SSH and HTTP access"
  vpc_id      = aws_vpc.jenkins_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-sg"
  }
}

resource "aws_instance" "jenkins_instance" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.jenkins_subnet.id
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    # Save all output to a log file (Redirecting output for debugging)
    exec > /var/log/user-data.log 2>&1
    set -x
    set -e

    # Wait for system to fully start
    sleep 30

    # Update package index and install necessary dependencies
    apt-get update
    apt-get install -y curl gnupg fontconfig openjdk-17-jre

    # Download Jenkins security key and save it
    curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | gpg --dearmor -o /usr/share/keyrings/jenkins-keyring.gpg

    # Add Jenkins APT repository, referencing the signed key
    echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.gpg] https://pkg.jenkins.io/debian-stable binary/" \
      > /etc/apt/sources.list.d/jenkins.list

    # Update package list again and install Jenkins
    apt-get update
    apt-get install -y jenkins

    # Start Jenkins and make it run on boot
    systemctl enable jenkins
    systemctl start jenkins
  EOF


  tags = {
    Name = "jenkins-instance"
  }
}

