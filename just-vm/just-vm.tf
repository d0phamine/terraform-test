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
  zone                     = "ru-central1-a"
}

locals {
  folder_id = "b1g665agp5589ntuqkr1"
  # service-accounts = toset([
  #   "lesson-service",
  # ])
  # catgpt-sa-roles = toset([
  #   "admin",
  # ])
}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2004-lts"
}

# data "yandex_compute_image" "centos" {
#     family = "centos-7"
# }

resource "yandex_vpc_network" "my-network" {}

resource "yandex_vpc_subnet" "my-subnet" {
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.my-network.id
  v4_cidr_blocks = ["10.5.0.0/24"]
}

resource "yandex_compute_instance" "my-vm" {
  name        = "my-vm"
  platform_id = "standard-v2"
  zone        = "ru-central1-a"

  resources {
    cores         = 2
    memory        = 1
    core_fraction = 5
  }

  boot_disk {
    initialize_params {
      type     = "network-hdd"
      size     = "30"
      image_id = data.yandex_compute_image.ubuntu.id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.my-subnet.id
    nat       = true
  }

  metadata = {
    foo      = "bar"
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

# resource "yandex_compute_instance" "my-group" {
#   count = 3
# #   name        = "my-group-$"
#   platform_id = "standard-v2"
#   zone        = "ru-central1-a"

#   resources {
#     cores         = 2
#     memory        = 1
#     core_fraction = 5
#   }

#   boot_disk {
#     initialize_params {
#       type     = "network-hdd"
#       size     = "30"
#       image_id = data.yandex_compute_image.centos.id
#     }
#   }

#   network_interface {
#     subnet_id = yandex_vpc_subnet.my-subnet.id
#     nat       = true
#   }

#   metadata = {
#     foo      = "bar"
#     ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
#   }
# }