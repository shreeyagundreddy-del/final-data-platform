terraform {
  backend "s3" {
    bucket         = "final-data-platform-terraform-state"
    key            = "final-data-platform/terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
  }
}
