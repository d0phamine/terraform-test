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

resource "yandex_iam_service_account" "service-accounts" {
  count = length(var.service_accounts)
  name  = element(var.service_accounts, count.index)
}

output "created_service_accounts" {
  value = [
    for acc in yandex_iam_service_account.service-accounts:
    "Service account: ${acc.name} - ${acc.id}"
  ]
}