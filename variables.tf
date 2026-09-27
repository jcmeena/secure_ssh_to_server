variable "aws_region" {
  type    = string
  default = "us-east-1"
}

# network 
variable "aws_vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "aws_vpc_az" {
  type    = string
  default = "us-east-1a"
}

variable "aws_vpc_public_subnet_cidr_block" {
  type    = string
  default = "10.0.1.0/24"
}

variable "name_security_group"{
    type = string
    default = "allow_ssh"
}


variable "tag_name_vpc"{
    type = string
    default = "dev-vpc"
}

variable "tag_name_internet_gw"{
    type = string
    default = "dev-igw"
}

variable "tag_name_subnet_public"{
    type = string
    default = "dev-public-subnet"
}

variable "tag_name_route_table"{
    type = string
    default = "dev-public-rt"
}

variable "tag_name_security_group"{
    type = string
    default = "dev-ssh-sg"
}



# Compute 
variable "name_key"{
    type = string
    default = "dev-ssh-key"
}

variable "aws_instance_ami"{
    type = string
    default = "ami-0b6d9d3d33ba97d99"
}

variable "aws_instance_type"{
    type = string
    default = "t3.micro"
}

variable "tag_name_aws_instance"{
    type = string
    default = "dev-ubuntu-vm"
}