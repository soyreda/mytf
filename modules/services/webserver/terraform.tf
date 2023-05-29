terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  /*backend "s3" {
    bucket         = "my-tf-test-bucket-bck"
    key            = "stage/services/webserver/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  }*/

}
/*provider "aws" {
  region = "us-west-2"
}*/

