provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "Dev" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Dev-vpc"
  }
}

resource "aws_subnet" "Dev" {
  vpc_id = aws_vpc.Dev.id
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "Dev-subnet"
  }
}

resource "aws_instance" "Dev" {
  ami           = "ami-06e85d4c3149db26a"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.Dev.id]
  subnet_id     = aws_subnet.Dev.id

  user_data = <<-EOF
#!/bin/bash
sudo yum update -y
sudo yum install -y httpd
sudo service httpd start
echo "Hello World" | sudo tee /var/www/html/index.html
EOF

  tags = {
    Name = "Dev-instance"
  }
}

resource "aws_security_group" "Dev" {
  name        = "Dev-security-group"
  description = "Allow HTTP traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Dev-security-group"
  }
}
