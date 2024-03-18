# DEV vars
# Имеет приоритет перед defaults
# Файл может быть назван terraform.tfvars
# или prod.auto.tfvars/dev.auto.tfvars
# Чтобы запустить с конкретным файлом использовать:
# terraform apply -var-file=...

folder_id              = "b1g665agp5589ntuqkr1"
compute_image_family   = "ubuntu-2004-lts"
folder_service_account = "folder-service"
region                 = "ru-central1-a"
default_cidr           = "10.5.0.0/24"
