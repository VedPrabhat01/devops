# This resource generates a new 4096-bit RSA key for SSH.
resource "tls_private_key" "assignment_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# This resource takes the public key from the generated key pair
# and uploads it to your AWS account.
resource "aws_key_pair" "generated_key" {
  key_name   = "assignment-key" # You can change this name if you like
  public_key = tls_private_key.assignment_key.public_key_openssh
}

# This resource saves the generated private key to a file on your
# local machine. This is useful if you ever need to SSH into
# the instances manually.
resource "local_file" "private_key_pem" {
  content         = tls_private_key.assignment_key.private_key_pem
  filename        = "assignment-key.pem"
  file_permission = "0400"
}
