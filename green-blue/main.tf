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

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2004-lts"
}

data "yandex_iam_service_account" "admin" {
  name = "folder-service"
}

resource "yandex_vpc_network" "my-network" {}

resource "yandex_vpc_subnet" "my-subnet" {
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.my-network.id
  v4_cidr_blocks = ["10.5.0.0/24"]
}

resource "yandex_vpc_address" "my-address" {
  name      = "my-address"
  folder_id = local.folder_id
  external_ipv4_address {
    zone_id = "ru-central1-a"
  }
}


resource "yandex_vpc_security_group" "my-security-group" {
  name        = "Webserver security group"
  description = "description for my security group"
  network_id  = yandex_vpc_network.my-network.id

  dynamic "ingress" {
    for_each = ["80", "443", "22"]

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


resource "yandex_compute_instance_group" "web-group" {
  name                = "web-compute-instance-group"
  folder_id           = local.folder_id
  service_account_id  = data.yandex_iam_service_account.admin.id
  deletion_protection = false
  instance_template {
    platform_id = "standard-v1"
    resources {
      memory = 2
      cores  = 2
    }
    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = data.yandex_compute_image.ubuntu.id
        size     = 5
      }
    }
    network_interface {
      network_id         = yandex_vpc_network.my-network.id
      subnet_ids         = ["${yandex_vpc_subnet.my-subnet.id}"]
      nat                = true
      security_group_ids = ["${yandex_vpc_security_group.my-security-group.id}"]
    }
    metadata = {
      user-data = templatefile("${path.module}/init.yml.tpl", { webserver = "apache2", f_name = "Gregory", l_name = "Sizov", names = ["john", "jake", "jenny", "samuel"] })
      ssh-keys  = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  variables = {
    test_key1 = "test_value1"
    test_key2 = "test_value2"
  }

  scale_policy {
    auto_scale {
      initial_size           = 2
      measurement_duration   = 300
      cpu_utilization_target = 80
      min_zone_size = 2
      max_size = 4
    }
  }

  allocation_policy {
    zones = ["ru-central1-a"]
  }

  deploy_policy {
    max_unavailable = 0
    max_creating    = 2
    max_expansion   = 1
    max_deleting    = 2
  }

  load_balancer {
    target_group_name        = "target-group"
    target_group_description = "target-group"
  }
}


resource "yandex_lb_network_load_balancer" "web-balancer" {
  name = "web-load-balancer"

  listener {
    name = "my-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
      #   address = yandex_vpc_address.my-address.id
    }
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.web-group.load_balancer.0.target_group_id

    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/index.html"
      }
    }
  }
}
