variable "aws_region" {
  description = "AWS region to deploy"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "jenkins-instance"
}

variable "vpc_name" {
  description = "Name tag for the VPC"
  type        = string
  default     = "jenkins-vpc"
}

variable "subnet_name" {
  description = "Name tag for the subnet"
  type        = string
  default     = "jenkins-subnet"
}

variable "route_table_name" {
  description = "Name tag for the route table"
  type        = string
  default     = "public-route-table"
}

variable "sg_name" {
  description = "Name of the security group"
  type        = string
  default     = "jenkins-sg"
}

variable "sg_description" {
  description = "Description of the security group"
  type        = string
  default     = "Allow SSH and HTTP access"
}

variable "ssh_port" {
  description = "Port for SSH access"
  type        = number
  default     = 22
}

variable "http_port" {
  description = "Port for Jenkins UI"
  type        = number
  default     = 8080
}

variable "tcp_protocol" {
  description = "TCP protocol for ingress rules"
  type        = string
  default     = "tcp"
}

variable "cidr_blocks" {
  description = "List of CIDR blocks allowed for ingress"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "egress_from_port" {
  description = "Egress from port"
  type        = number
  default     = 0
}

variable "egress_to_port" {
  description = "Egress to port"
  type        = number
  default     = 0
}

variable "egress_protocol" {
  description = "Egress protocol (use -1 for all)"
  type        = string
  default     = "-1"
}

variable "egress_cidr_blocks" {
  description = "List of CIDR blocks for egress traffic"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
