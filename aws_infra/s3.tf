resource "aws_s3_bucket" "data_bucket" {
  bucket = "openskynetwork-bucket"
}

resource "aws_s3_bucket" "config_bucket" {
  bucket = "openskynetwork-config-bucket"
}

resource "aws_s3_bucket_object" "config_object" {
  bucket = aws_s3_bucket.config_bucket.id
  key    = "step_function.json"
  source = "../config/step_function.json"

  etag = filemd5("${path.module}/../config/step_function.json")
}