provider "aws" {
  region  = "ca-central-1"
  version = "~> 2.70"
  profile = "sam"
}


terraform {
  backend "s3" {
    bucket = "samirbucketgoodone"
    key    = "global/eip/terraform.tfstate"
    region = "ca-central-1"
  }
}