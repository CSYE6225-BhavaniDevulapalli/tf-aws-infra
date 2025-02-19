

provider "aws" {
  region  = var.aws_region 
profile = var.aws_profile
}

resource "aws_instance" "example" {
  ami = "INVALID_AMI_ID" # This is not a valid AMI ID
  instance_type = "t2.micro"
}
