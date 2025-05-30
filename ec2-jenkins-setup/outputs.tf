output "jenkins_url" {
  description = "Public IP to access the Jenkins UI in your browser"
  value       = "http://${aws_instance.jenkins_instance.public_ip}:8080"
}

output "ssh_access" {
  description = "SSH command to connect to the Jenkins EC2 instance"
  value       = "ssh -i ${aws_key_pair.jenkins_key.key_name}.pem ubuntu@${aws_instance.jenkins_instance.public_ip}"
}

output "jenkins_admin_password" {
  description = "Instructions to retrieve Jenkins admin password"
  value       = "After SSHing into the instance, run: sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
}
