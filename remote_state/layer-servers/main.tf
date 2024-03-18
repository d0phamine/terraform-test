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
    key    = "dev/server/terraform.tfstate"
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

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
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
}

resource "yandex_vpc_security_group" "my-security-group" {
  name        = "Webserver security group"
  description = "description for my security group"
  network_id  = data.terraform_remote_state.network.outputs.my-network

  dynamic "ingress" {
    for_each = ["80", "443"]

    content {
      protocol       = "TCP"
      description    = "rule1 description"
      v4_cidr_blocks = ["0.0.0.0/0"]
      port           = ingress.value
    }
  }

  egress {
    protocol       = "ANY"
    description    = "rule2 description"
    v4_cidr_blocks = ["0.0.0.0/0"]
    # from_port      = -1
    # to_port        = -1
  }
}

output "network_details" {
  value = data.terraform_remote_state.network
}

output "server_sg_id" {
  value = yandex_vpc_security_group.my-security-group.id
}