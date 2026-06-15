terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1" # Your selected Stockholm region
}

# 1. NEW: Dynamically fetch the latest Amazon Linux 2023 AMI for this region
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"] # Matches the official modern AL2023 images
  }
}

# 2. Create the Security Group
resource "aws_security_group" "todo_app_sg" {
  name        = "todo-app-sg"
  description = "Allow web and SSH traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"] # Allows anyone to connect
}
}

# 3. Create the EC2 Virtual Server
resource "aws_instance" "todo_app_server" {
  # CHANGED: Uses the dynamic lookup data from above instead of a hardcoded ID
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.todo_app_sg.id]
  key_name               = "todo-app-key"

# Your automated script that bootstraps Docker and starts the app
  user_data = <<-EOT
    #!/bin/bash
    # 1. Update system and install required tools
    yum update -y
    yum install -y git docker
    
    # 2. Start Docker service
    systemctl enable docker
    systemctl start docker

    # 3. Clone your project directly from GitHub
    # NOTE: Replace the URL below with your actual GitHub repository URL!
    cd /home/ec2-user
    git clone https://github.com
    cd getting-started-app

    # 4. Build and run your local code using Docker
    docker build -t todo-app .
    docker run -d -p 80:3000 --restart always todo-app
  EOT

  tags = {
    Name = "todo-app-server"
  }
}

