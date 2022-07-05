resource "aws_s3_bucket" "s3_bucket" {
  bucket = "${var.name}-bucket"
}

resource "aws_s3_object" "log_directory" {
  bucket = aws_s3_bucket.s3_bucket.id
  key    = "logs/"

}

resource "aws_s3_object" "image_directory" {
  bucket = aws_s3_bucket.s3_bucket.id
  key    = "images/"

}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle_policy" {
  bucket = aws_s3_bucket.s3_bucket.id

  rule {
    id = "logs-lifecycle-policy"

    filter {
      prefix = "logs/"
    }

    expiration {
      days = 90
    }

    status = "Enabled"
  }

  rule {
    id = "images-lifecycle-policy"

    filter {
      prefix = "images/"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    status = "Enabled"
  }
}