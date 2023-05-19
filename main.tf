resource "aws_s3_bucket" "example" {
  bucket = "my-tf-test-bucket-bck"

  tags = {
    Name = "My bucket"
  Environment = "Dev" }

}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.example.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.example.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "example" {

  bucket                  = aws_s3_bucket.example.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-up-and-running-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
module "ec2-instance" {

  source        = "terraform-aws-modules/ec2-instance/aws"
  ami           = "ami-0fcf52bcf5db7b003"
  version       = "5.0.0"
  instance_type = "t2.micro"
  name          = "single-instance"

}
resource "aws_instance" "example" {
	ami = "ami-0fcf52bcf5db7b003"
	instance_type = "t2.micro"

	tags = {
		Name = "terraform-example"
}
}

