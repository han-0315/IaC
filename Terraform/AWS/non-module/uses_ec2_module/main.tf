locals {
  env = {
    dev = {
      instance_type = "t3.micro"
      key_name      = "m1"
      namespace     = "dev"
    }
    prod = {
      instance_type = "t3.medium"
      key_name      = "m1"
      namespace     = "prod"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

module "ec2_aws_amazone" {
  for_each          = local.env
  source            = "../../module/ec2"
  key_name          = each.value.key_name
  ec2_instance_type = each.value.instance_type
  namespace         = each.value.namespace
}

# output.tf
output "module_output_instance_public_ip" {
  value = [
    for k in module.ec2_aws_amazone : k.instance_public_ip
  ]
}
