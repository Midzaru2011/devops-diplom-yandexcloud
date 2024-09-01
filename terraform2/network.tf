#Публичная сеть и ВМ
resource "yandex_vpc_network" "netology-network" {
  name = var.vpc_name
}

resource "yandex_vpc_subnet" "subnet-zones" {
  count          = 3
  name           = "subnet-${var.subnet-zone[count.index]}"
  zone           = "${var.subnet-zone[count.index]}"
  network_id     = "${yandex_vpc_network.netology-network.id}"
  v4_cidr_blocks = [ "${var.cidr.stage[count.index]}" ]
}


data "yandex_compute_image" "ubuntu" {
  family = var.public_image
}
