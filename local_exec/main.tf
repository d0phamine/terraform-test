terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

resource "null_resource" "command1" {
  provisioner "local-exec" {
    command = "echo Terraform start: $(date) >> log.txt"
  }
}

resource "null_resource" "command2" {
  provisioner "local-exec" {
    command = "ping -c 5 ya.ru"
  }
  depends_on = [null_resource.command1]
}

resource "null_resource" "command3" {
  provisioner "local-exec" {
    command     = "print('123')"
    interpreter = ["python3", "-c"]
  }
}
