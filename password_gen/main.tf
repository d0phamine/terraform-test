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

resource "random_string" "rds_password" {
  length  = 12
  special = true
  override_special = "!#$&"
}

resource "yandex_lockbox_secret" "my_secret" {
  name = "/prod/mysql"
  description = "pass for rds mysql"
  folder_id = local.folder_id
}

data "yandex_lockbox_secret" "rds_password" {
    name = "/prod/mysql"
    depends_on = [ yandex_lockbox_secret.my_secret ]
}

output "rds_password" {
  value = data.yandex_lockbox_secret.rds_password.secret_id
}