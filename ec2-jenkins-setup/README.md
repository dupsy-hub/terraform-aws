# EC2 Jenkins Setup with Terraform

This project provisions an AWS EC2 instance with Jenkins preinstalled using Terraform. It is part of a DevOps workflow for automating infrastructure and CI/CD environments.

---

## 📦 Project Structure

```
ec2-jenkins-setup/
├── screenshots/
│   ├── jenkins-dashboard.png
│   ├── jenkins-getting-started.png
│   ├── jenkins-create-admin-user.png
│   ├── jenkins-is-ready.png
│   ├── jenkins-status-active-running.png
│   └── README.md    # Docs for screenshots (preview gallery)
├── script/
│   └── install_jenkins.sh
├── .gitignore
├── backend.tf
├── keypair.tf
├── main.tf
├── network.tf
├── outputs.tf
├── provider.tf
├── README.md        # Main project documentation
├── sg.tf
├── terraform.tfvars.example
└── variables.tf
```

---

## 🚀 Getting Started

### 1. Prerequisites

- AWS CLI installed and configured
- Terraform installed
- Remote Backend Setup (S3 & DynamoDB)

  To store your Terraform state remotely and enable state locking, you’ll need:
  An S3 bucket for storing the .tfstate file
  A DynamoDB table for state locking
  Proper IAM permissions to access both

  ✅ Step 1: Create an S3 Bucket (via AWS Console)
  Go to the AWS S3 Console
  Click “Create bucket”
  Set a unique name like jenkins-tf-state-yourname # Bucket name must be globally unique across all AWS users.
  Choose a region (e.g., us-east-1)
  Enable Bucket Versioning (recommended)
  Click “Create bucket”

  ✅ Step 2: Create a DynamoDB Table for Locking
  Go to the AWS DynamoDB Console
  Click “Create table”
  Table name: terraform-locks
  Partition key: LockID (Type: String)
  Leave all other settings at default
  Click “Create table”

  ✅ Step 3: IAM Permissions (Recommended)
  Go to IAM Console
  Click Users or Roles
  Select the user or role Terraform will use
  Click "Add permissions" or "Add inline policy"

  Ensure your IAM user or role has access to:
  s3:PutObject, s3:GetObject, s3:ListBucket, etc.
  dynamodb:PutItem, dynamodb:GetItem, dynamodb:DeleteItem, dynamodb:Scan

You can attach the managed policy AmazonS3FullAccess and AmazonDynamoDBFullAccess for testing purposes, or create a custom least-privilege policy.

✅ Step 4: Update backend.tf
After creating the S3 bucket and DynamoDB table, configure your backend.tf like this:

terraform {
backend "s3" {
bucket = "jenkins-tf-state-yourname"
key = "dev/terraform.tfstate"
region = "us-east-1"
dynamodb_table = "terraform-locks"
encrypt = true
}
}

✅ Step 5: Initialize Terraform Backend

terraform init

Terraform will detect the backend configuration and prompt you to migrate state. Type yes to proceed.
This setup ensures that your Terraform state is:
Stored securely in S3
Versioned for safety
Locked during changes to avoid race conditions

### 2. Clone Repository

```bash
git clone https://github.com/<your-username>/terraform-aws.git
cd terraform-aws/ec2-jenkins-setup
```

### 3. Configure Your Variables

Copy the example file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values:

```hcl
aws_region         = "us-east-1"
ami_id             = "ami-xxxxxxxxxxxxxxxxx"
instance_type      = "t2.micro"
key_name           = "project-key"
availability_zone  = "us-east-1a"
```

### 🔐Key Pair

- The `keypair.tf` file generates a key pair automatically for use in Terraform

### 🧭 Finding AMI ID

Before deploying with Terraform, you need a valid Ubuntu AMI ID (e.g., Ubuntu 22.04). You can log into AWS to find a suitable Ubuntu 22.04 AMI manually or you can optionally use the AWS CLI to find your own AMI with this command:

```bash
aws ec2 describe-images \
  --owners 099720109477 \
  --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*" \
  --query "Images[*].{ID:ImageId, Name:Name}" \
  --region us-east-1 \
  --output table
```

## Understanding CIDR Blocks

When creating a VPC in AWS, you need to define a CIDR block — this sets the range of private IP addresses available for your network.

👉 What is CIDR?
CIDR stands for Classless Inter-Domain Routing. It’s written in this format:
<Starting IP Address>/<Prefix Length>
✅ Example:
cidr_block = "172.16.0.0/16"
This means:

Starting IP: 172.16.0.0
Prefix Length: /16 (allows about 65,000 IP addresses)

🛑 Important
Always choose a range that doesn’t overlap with other networks you're using (like your home Wi-Fi or office network).

For most projects, something like "172.16.0.0/16" or "10.0.0.0/16" works well.

CIDR Calculator Tip:
If you’re not sure how many IP addresses a CIDR block provides or which block to use, you can use a free CIDR calculator online.

🔗 Try this: https://www.ipaddressguide.com/cidr

How to use it:
Enter a CIDR block like 172.16.0.0/16.
It will show:
Total number of IP addresses
First and last usable IPs
Network and broadcast address

This helps you pick the right size for your VPC or subnet without guessing.

✅ Tip: For most small projects, /16 or /24 is enough.

## VPC Setup Options

For this project, you can either:

- Create a custom VPC (as shown in the Terraform configuration), or
- Use AWS's default VPC (simpler and faster for testing)

❌ Common VPC Issues & Troubleshooting
If you choose to create your own VPC and encounter errors, here are some common causes:

- Overlapping CIDR blocks
  Make sure the CIDR block for your new VPC doesn't conflict with existing VPCs or subnets.

- Region mismatch
  Ensure the AWS region in your Terraform provider matches the region set in your AWS CLI configuration.

- VPC quota limit
  AWS allows only a limited number of VPCs per region (default is 5). If you're at the limit, either delete unused VPCs or request a quota increase from AWS.

⚠️ Using the Default VPC (Optional)
If you want a quicker setup and don't need a custom network, you can use the default VPC provided by AWS.
Here's how to do it in Terraform:

# Use the default VPC

data "aws_vpc" "default" {
default = true
}

data "aws_subnet_ids" "default" {
vpc_id = data.aws_vpc.default.id
}

resource "aws_instance" "jenkins_instance" {

# Use the first available default subnet

subnet_id = data.aws_subnet_ids.default.ids[0]

# other instance configs...

}

✅ Note: Using the default VPC is suitable for testing and learning environments. For production setups, it's recommended to use a custom VPC for better control and security.

## 🛠 Deploy Infrastructure

1.  Initialize Terraform

```bash
terraform init
```

2. Plan Configuration

```bash
terraform plan
```

3. Apply Configuration

```bash
terraform apply
```

Confirm with `yes` or use:

```bash
terraform apply --auto-approve
```

## 💻 Access Jenkins

Once Terraform finishes applying your configuration, it will display useful output values to help you access and manage your Jenkins instance.

🌐 Jenkins URL
Open Jenkins in your browser using the public IP address:

    http://<public-ip>:8080

Terraform will automatically output the full URL like:

    jenkins_url = "http://18.233.123.45:8080"  # Example url

🔐 SSH Access
To connect to the Jenkins EC2 instance via SSH, use the command provided in the output:
ssh -i jenkins-key.pem ubuntu@<public-ip>
Terraform will output something like:
ssh_access = "ssh -i jenkins-key.pem ubuntu@18.233.123.45"

🔑 Retrieve Jenkins Admin Password
After SSHing into the instance, run the following command inside the terminal:
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
This password is needed to unlock Jenkins during the initial setup in your browser. Terraform provides the instruction as part of the output:
jenkins_admin_password = "After SSHing into the instance, run: sudo cat /var/lib/jenkins/secrets/initialAdminPassword"

## 🧹 Clean Up

To tear down all infrastructure created by Terraform:
terraform destroy

Or run without confirmation prompts:
terraform destroy --auto-approve

🔁 Remove Backend Resources (S3 & DynamoDB)
Terraform won't automatically delete the remote backend resources. To remove them manually:

Delete DynamoDB Table:
Go to the DynamoDB Console, select your table, and choose Delete table.

Delete S3 Bucket:
Go to the S3 Console, select your bucket, empty it, and then click Delete.

## 🧾 Project Info

Project Name: EC2 Jenkins Setup with Terraform
Purpose: Automate the provisioning of a Jenkins server on AWS EC2 for CI/CD workflows
Technologies Used: Terraform, AWS EC2, Jenkins, Shell Script
Repository URL: https://github.com/DevOps-Playground-CM/terraform-aws

```

```
