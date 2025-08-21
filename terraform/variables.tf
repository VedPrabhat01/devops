variable "aws_region" {
  description = "AWS region to deploy in"
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "frontend_image" {
  description = "DockerHub image for frontend"
  default     = "vedprabhat/assignment-frontend:latest"
}

variable "backend_image" {
  description = "DockerHub image for backend"
  default     = "vedprabhat/assignment-backend:latest"
}

variable "dockerhub_user" {
  description = "DockerHub username"
}

