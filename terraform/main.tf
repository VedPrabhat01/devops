# Create VPC
resource "aws_vpc" "assignment_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "assignment-vpc"
  }
}

# Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.assignment_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"
  tags = {
    Name = "public-subnet"
  }
}

# Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.assignment_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.aws_region}a"
  tags = {
    Name = "private-subnet"
  }
}

# Internet Gateway for Public Subnet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.assignment_vpc.id
  tags = {
    Name = "assignment-igw"
  }
}

# Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.assignment_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt"
  }
}

# Associate Public Subnet with Public Route Table
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# NAT Gateway for Private Subnet
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id
  tags = {
    Name = "assignment-nat-gw"
  }
  depends_on = [aws_internet_gateway.igw]
}

# Private Route Table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.assignment_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "private-rt"
  }
}

# Associate Private Subnet with Private Route Table
resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

# FRONTEND EC2 Instance (Public Subnet)
resource "aws_instance" "frontend" {
  ami             = "ami-0f918f7e67a3323f0" # Ubuntu 22.04 in ap-south-1
  instance_type   = var.instance_type
  subnet_id       = aws_subnet.public_subnet.id
  key_name        = aws_key_pair.generated_key.key_name
  security_groups = [aws_security_group.frontend_sg.id]

  tags = {
    Name = "FRONTEND"
  }

  # This connection block is now only used for the file provisioner.
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.assignment_key.private_key_pem
    host        = self.public_ip
    timeout     = "4m"
  }

  # This provisioner just copies the script. It does NOT run it.
  provisioner "file" {
    source      = "../script/frontend.sh"
    destination = "/home/ubuntu/frontend.sh"
  }
}

# BACKEND EC2 Instance (Private Subnet)
resource "aws_instance" "backend" {
  ami             = "ami-0f918f7e67a3323f0" # Ubuntu 22.04 in ap-south-1
  instance_type   = var.instance_type
  subnet_id       = aws_subnet.private_subnet.id
  key_name        = aws_key_pair.generated_key.key_name
  security_groups = [aws_security_group.backend_sg.id]

  # This new line fixes the timing issue.
  depends_on = [aws_route_table_association.private_assoc]

  tags = {
    Name = "BACKEND"
  }

  connection {
    type         = "ssh"
    user         = "ubuntu"
    private_key  = tls_private_key.assignment_key.private_key_pem
    host         = self.private_ip
    bastion_host = aws_instance.frontend.public_ip
    timeout      = "5m"
  }

  # This provisioner copies and runs the backend script.
  provisioner "file" {
    source      = "../script/backend.sh"
    destination = "/home/ubuntu/backend.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/backend.sh",
      "sudo /home/ubuntu/backend.sh"
    ]
  }
}

# This resource breaks the cycle. It runs AFTER both instances are created.
resource "null_resource" "deploy_frontend_app" {
  # This ensures this resource runs after the backend instance is fully available.
  depends_on = [aws_instance.backend]

  # This connection block connects to the FRONTEND instance.
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.assignment_key.private_key_pem
    host        = aws_instance.frontend.public_ip
    timeout     = "4m"
  }

  # This provisioner now runs the frontend script, passing the backend's IP.
  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/frontend.sh",
      "sudo /home/ubuntu/frontend.sh ${aws_instance.backend.private_ip}"
    ]
  }
}
