terraform {
  backend "s3" {
    bucket = "kane1-t101study-tfstate"
    key    = "dev/terraform.tfstate"
    region = "ap-northeast-2"
    dynamodb_table = "terraform-locks"
    # encrypt        = true
  }
}