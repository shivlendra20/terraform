provider "aws" {
  region     = "ap-south-1"
  #access_key = var.aws_access_key
  #secret_key = var.aws_secret_key
  endpoints {
    sts = "https://sts.ap-south-1.amazonaws.com"
  }
}
