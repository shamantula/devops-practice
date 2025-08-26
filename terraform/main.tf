# --- provider ---
provider "aws" {
  region = "ap-south-1"   # change to your region
}
resource "aws_key_pair" "my_key" {
  key_name   = "my-terraform-key"         # name shown in AWS console
  public_key = file("~/.ssh/id_ed25519.pub")  # path to your existing public key
}
# --- get default VPC ---
data "aws_vpc" "default" {
  default = true
}

 #--- get default subnet(s) ---
data "aws_subnet" "selected" {
  filter {
    name   = "cidrBlock"
    values = ["172.31.255.0/24"] # replace with your subnet CIDR
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# --- security group (allow SSH + HTTP) ---
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- EC2 Instance ---
resource "aws_instance" "my_ec2" {
  ami           = "ami-0f918f7e67a3323f0"   # Ubuntu 22.04 LTS (Mumbai region, change if needed)
  instance_type = "t3.micro"

  subnet_id              = data.aws_subnet.selected.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  count = 1   # <-- This creates 3 EC2 instances
key_name = aws_key_pair.my_key.key_name # use the key pair created above
  tags = {
    Name = "web-1"
  }
}
