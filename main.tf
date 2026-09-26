# Automatically fetches your workstation's public IP address
data "http" "my_ip" {
  url = "https://ifconfig.me/ip"
}


resource "aws_vpc" "lab_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = { Name = "dev-vpc" }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.lab_vpc.id

  tags = { Name = "dev-igw" }
}


resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true

  tags = { Name = "dev-public-subnet" }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.lab_vpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "dev-public-rt" }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "ssh_sg" {
  name        = "allow_ssh"
  description = "Only allow SSH from my workstation"
  vpc_id      = aws_vpc.lab_vpc.id

  ingress {
    description = "SSH from developer IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "dev-ssh-sg" }
}


resource "aws_key_pair" "deployer" {
  key_name   = "dev-ssh-key"
  public_key = file("~/.ssh/id_rsa.pub") # Adjust path to your public key if needed
}



resource "aws_instance" "web_server" {
  ami           = "ami-0e5497a77ef21b5ac" # Ubuntu 24.04 LTS AMI in us-east-1
  instance_type = "t3.micro"             # AWS Free Tier eligible

  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.ssh_sg.id]
  key_name               = aws_key_pair.deployer.key_name

  tags = { Name = "dev-ubuntu-vm" }
}
