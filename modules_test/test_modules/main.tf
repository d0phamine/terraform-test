terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  service_account_key_file = "../tf_key.json"
  folder_id                = local.folder_id
  #   zone                     = "ru-central1-a"
}

locals {
  folder_id = "b1g665agp5589ntuqkr1"
}

module "vpc-default" {
  source = "../modules/yc_network"
  # source = "https://github.com/d0phamine/terraform-test.git//modules_test/modules/yc_network"

}

module "vpc-dev" {
  source               = "../modules/yc_network"
  env                  = "dev"
  vpc_cidr             = "10.100.0.0/16"
  public_subnet_cidrs  = ["10.100.0.0/24", "10.100.2.0/24"]
  private_subnet_cidrs = ["10.100.11.0/24", "10.100.22.0/24"]
}

module "vpc-prod" {
  source               = "../modules/yc_network"
  env                  = "prod"
  vpc_cidr             = "10.10.0.0/16"
  public_subnet_cidrs  = ["10.10.0.0/24", "10.10.2.0/24"]
  private_subnet_cidrs = ["10.10.11.0/24", "10.10.22.0/24"]
}

///////////////////////////////////////////////////////////

output "prod_public_subnet_ids" {
  value = module.vpc-prod.public_subnet_ids
}

output "prod_private_subnet_ids" {
  value = module.vpc-prod.private_subnet_ids
}

output "dev_public_subnet_ids" {
  value = module.vpc-dev.public_subnet_ids
}

output "dev_private_subnet_ids" {
  value = module.vpc-dev.private_subnet_ids
}
