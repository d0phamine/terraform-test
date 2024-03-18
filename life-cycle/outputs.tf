output "subnet_id" {
  value = yandex_vpc_subnet.my-subnet.id
}

output "network_id" {
  value = yandex_vpc_network.my-network.id
}

output "public_ip" {
    value = yandex_vpc_address.my-address.external_ipv4_address[0].address
}

output "security_group_id" {
    value = yandex_vpc_security_group.my-security-group.id
}