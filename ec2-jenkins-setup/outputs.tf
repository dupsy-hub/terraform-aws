output "public_ip" {
  description = "Public IP of the Jenkins EC2 instance"
  value       = aws_instance.jenkins_instance.public_ip
}
