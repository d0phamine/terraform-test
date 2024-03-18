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

# Ищет в мапе значение под ключом var.env == 'dev'
data "yandex_compute_image" "ubuntu" {
  family = lookup(var.distr_typo, var.env)
}

resource "yandex_vpc_network" "my-network" {}

resource "yandex_vpc_subnet" "my-subnet" {
  zone           = var.region
  network_id     = yandex_vpc_network.my-network.id
  v4_cidr_blocks = [var.default_cidr]
}

resource "yandex_vpc_security_group" "my-security-group" {
  name        = "Webserver security group"
  description = "description for my security group"
  network_id  = yandex_vpc_network.my-network.id

  dynamic "ingress" {
    for_each = var.allow_port

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

resource "yandex_compute_instance" "my-vm" {
  name        = "my-vm"
  platform_id = "standard-v2"
  zone        = var.region 

  resources {
    cores         = 2
    memory        = var.env == "prod" ? 2 : 1
    core_fraction = 5
  }

  boot_disk {
    initialize_params {
      type     = "network-hdd"
      size     = var.env == "prod" ? 40 : 30 
      image_id = data.yandex_compute_image.ubuntu.id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.my-subnet.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}
