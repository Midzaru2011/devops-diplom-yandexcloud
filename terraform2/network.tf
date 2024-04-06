#Публичная сеть и ВМ
resource "yandex_vpc_network" "netology-network" {
  name = var.vpc_name
}

resource "yandex_vpc_subnet" "subnet-a" {
  name           = "central-a"
  zone           = var.zone_a
  network_id     = yandex_vpc_network.netology-network.id
  v4_cidr_blocks = ["10.0.1.0/24"]
}

resource "yandex_vpc_subnet" "subnet-b" {
  name           = "central-b"
  zone           = var.zone_b
  network_id     = yandex_vpc_network.netology-network.id
  v4_cidr_blocks = ["10.0.2.0/24"]
}

resource "yandex_vpc_subnet" "subnet-d" {
  name           = "central-d"
  zone           = var.zone_d
  network_id     = yandex_vpc_network.netology-network.id
  v4_cidr_blocks = ["10.0.3.0/24"]
}

data "yandex_compute_image" "ubuntu" {
  family = var.public_image
}
