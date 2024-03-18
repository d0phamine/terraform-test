output "vpc_id" {
  value = yandex_vpc_network.my-network.id
}

output "public_subnet_ids" {
  value = yandex_vpc_subnet.public_subnet[*].id
}

output "private_subnet_ids" {
    value = yandex_vpc_subnet.private_subnet[*].id
}

output "vpc_gateway_id" {
    value = yandex_vpc_gateway.my-yandex_vpc_gateway.id
}