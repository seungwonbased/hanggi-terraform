provider "aws" {
  region = var.aws_region
}

resource "aws_ecr_repository" "main" {
  name = var.ecr_repository_name

  image_scanning_configuration {
    scan_on_push = true
  }
}

output "ecr_repository_url" {
  value = aws_ecr_repository.main.repository_url
}