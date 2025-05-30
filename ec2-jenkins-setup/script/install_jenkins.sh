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