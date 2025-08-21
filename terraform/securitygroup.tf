# Security Group for FRONTEND (Public subnet)
resource "aws_security_group" "frontend_sg" {
  name        = "frontend-sg"
  description = "Allow HTTP and SSH from anywhere"
  vpc_id      = aws_vpc.assignment_vpc.id

  ingress {
    description = "SSH from public"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from public"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # This rule is necessary for the bastion host connection to the private instance.
  ingress {
    description = "Allow SSH from self for Bastion"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    self        = true
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for BACKEND (Private subnet)
resource "aws_security_group" "backend_sg" {
  name        = "backend-sg"
  description = "Allow traffic only from frontend"
  vpc_id      = aws_vpc.assignment_vpc.id

  # Allow SSH traffic from the frontend instance for provisioning
  ingress {
    description     = "Allow SSH from frontend SG"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend_sg.id]
  }

  # Allow application traffic from the frontend instance
  ingress {
    description     = "Allow app traffic from frontend SG"
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend_sg.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
