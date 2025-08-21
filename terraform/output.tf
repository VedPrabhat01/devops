# This output will display the public IP of the frontend instance.
output "frontend_public_ip" {
  description = "The public IP address of the frontend EC2 instance"
  value       = aws_instance.frontend.public_ip
}

# This output will display the private IP of the backend instance.
output "backend_private_ip" {
  description = "The private IP address of the backend EC2 instance"
  value       = aws_instance.backend.private_ip
}

# This provides a convenient, clickable URL for your application.
output "application_url" {
  description = "The URL to access the web application"
  value       = "http://${aws_instance.frontend.public_ip}"
}