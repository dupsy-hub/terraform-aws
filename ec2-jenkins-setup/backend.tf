terraform {
  backend "s3" {
    bucket         = "jenkins-setup-s3-bucket"
    key            = "jenkins/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "jenkins-setup-dynamodb"
    encrypt        = true
  }
}
