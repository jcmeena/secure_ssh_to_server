# Automatically fetches your workstation's public IP address
data "http" "my_ip" {
  url = "https://ifconfig.me/ip"
}


resource "aws_vpc" "lab_vpc" {
  cidr_block           = var.aws_vpc_cidr_block
  enable_dns_hostnames = true

  tags = { Name = var.tag_name_vpc }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.lab_vpc.id

  tags = { Name = var.tag_name_internet_gw }
}


resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = var.aws_vpc_public_subnet_cidr_block
  availability_zone       = var.aws_vpc_az
  map_public_ip_on_launch = true

  tags = { Name = var.tag_name_subnet_public }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.lab_vpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = var.tag_name_route_table }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "ssh_sg" {
  name        = var.name_security_group
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

  tags = { Name = var.tag_name_security_group }
}


resource "aws_key_pair" "deployer" {
  key_name   = var.name_key
  public_key = file("~/.ssh/id_rsa.pub") # Adjust path to your public key if needed
}



resource "aws_instance" "web_server" {
  ami           = var.aws_instance_ami
  instance_type = var.aws_instance_type

  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.ssh_sg.id]
  key_name               = aws_key_pair.deployer.key_name

  tags = { Name = var.tag_name_aws_instance }
}
