#!/bin/bash
set -e
terraform init --upgrade
terraform validate
terraform fmt
terraform plan
terraform apply -y