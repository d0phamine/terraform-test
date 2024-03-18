variable "folder_id" {
  type    = string
  default = "b1g665agp5589ntuqkr1"
}

variable "compute_image_family" {
  type    = string
  default = "ubuntu-2004-lts"
}

variable "folder_service_account" {
  type    = string
  default = "folder-service"
}

variable "region" {
  type    = string
  default = "ru-central1-a"
}

variable "default_cidr" {
  type    = string
  default = "10.5.0.0/24"
}

variable "allow_port" {
  type = list(string)
  default = [ "80", "443", "22" ]
}
