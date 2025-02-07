provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "flask_app_sg" {
  name        = "flask-app-sg"
  description = "Allow SSH and HTTP access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH (consider restricting this for security)
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP traffic
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "flask_app" {
  ami             = "ami-0c55b159cbfafe1f0" # Amazon Linux 2023 AMI
  instance_type   = "t2.micro"
  key_name        = "MikeKey"
  security_groups = [aws_security_group.flask_app_sg.name]

  tags = {
    Name = "flask-app-instance"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y python3 git
              EOF

  provisioner "file" {
    source      = "../ansible"
    destination = "/home/ec2-user/ansible"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/MikeKey")
      host        = self.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod -R 755 /home/ec2-user/ansible"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/MikeKey")
      host        = self.public_ip
    }
  }
}

output "ec2_public_ip" {
  value = aws_instance.flask_app.public_ip
}
