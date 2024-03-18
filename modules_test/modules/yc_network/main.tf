locals {
  folder_id = "b1g665agp5589ntuqkr1"
}

data "yandex_compute_image" "ubuntu" {
  family = var.image
}

resource "yandex_vpc_network" "my-network" {
    name = "${var.env}-vpc-network"
}

//////////////////////////////////////////////////////

resource "yandex_vpc_subnet" "public_subnet" {
  count          = length(var.public_subnet_cidrs)
  zone           = var.availability_zone
  network_id     = yandex_vpc_network.my-network.id
  v4_cidr_blocks = [var.public_subnet_cidrs[count.index]]
  route_table_id = yandex_vpc_route_table.my-route_table.id
  name = "${var.env}-public-${count.index + 1}"
}

resource "yandex_vpc_route_table" "my-route_table" {
  name = "${var.env}-route-public-subnets"
  network_id = yandex_vpc_network.my-network.id
  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.my-yandex_vpc_gateway.id
  }
}

resource "yandex_vpc_gateway" "my-yandex_vpc_gateway" {
  name = "${var.env}-nat-gateway"
  shared_egress_gateway {}
}

//////////////////////////////////////////////////////

resource "yandex_vpc_subnet" "private_subnet" {
  count          = length(var.private_subnet_cidrs)
  zone           = var.availability_zone
  network_id     = yandex_vpc_network.my-network.id
  v4_cidr_blocks = [var.private_subnet_cidrs[count.index]]
  name = "${var.env}-private-${count.index + 1}"
}
