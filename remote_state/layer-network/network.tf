terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  backend "s3" {
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }
    bucket = "project-kgb-terraform-state"
    key    = "dev/network/terraform.tfstate"
    region = "ru-central1-a"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true # Необходимая опция Terraform для версии 1.6.1 и старше.
    skip_s3_checksum            = true
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  service_account_key_file = "../../tf_key.json"
  folder_id                = local.folder_id
  zone                     = "ru-central1-a"
}

locals {
  folder_id = "b1g665agp5589ntuqkr1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2004-lts"
}

resource "yandex_vpc_network" "my-network" {}

resource "yandex_vpc_subnet" "my-subnet" {
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.my-network.id
  v4_cidr_blocks = [var.vpc_cidr]
}

resource "yandex_vpc_address" "my-address" {
  name      = "my-address"
  folder_id = local.folder_id
  external_ipv4_address {
    zone_id = "ru-central1-a"
  }
}

resource "yandex_vpc_gateway" "my-gateway" {
  name = "my-gateway"
}

output "vpc_id" {
  value = yandex_vpc_subnet.my-subnet.id
}

output "my-network" {
  value = yandex_vpc_network.my-network.id
}

output "vpc_cidr" {
  value = yandex_vpc_subnet.my-subnet.v4_cidr_blocks
}