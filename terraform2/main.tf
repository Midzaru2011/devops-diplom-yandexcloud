resource "yandex_compute_instance" "master" {  
  name                      = local.instance_master
  zone                      = var.zone_a
  hostname                  = local.instance_master
  allow_stopping_for_update = true
  platform_id = "standard-v2"

 
  scheduling_policy {
  preemptible = true  // Прерываемая ВМ
  }

  resources {
    cores         = var.public_resources.cores
    memory        = var.public_resources.memory
    core_fraction = var.public_resources.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id    = data.yandex_compute_image.ubuntu.image_id
      type        = "network-hdd"
      size        = "50"
    }
  }

  network_interface {
    
    subnet_id  = yandex_vpc_subnet.subnet-a.id
    nat        = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
  provisioner "file" {
    source      = "~/.ssh/id_rsa"
    destination = "/home/ubuntu/.ssh/id_rsa"
    
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host        = yandex_compute_instance.master.network_interface[0].nat_ip_address
    }
  }

   provisioner "remote-exec" {
    inline = [
      "chmod 600 /home/ubuntu/.ssh/id_rsa"
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host        = yandex_compute_instance.master.network_interface[0].nat_ip_address
    }
  }
}

 
resource "yandex_compute_instance" "worker1" {  
  name                      = local.instance_worker1
  zone                      = var.zone_b
  hostname                  = local.instance_worker1
  allow_stopping_for_update = true
  platform_id = "standard-v2"

 
  scheduling_policy {
  preemptible = true  // Прерываемая ВМ
  }

  resources {
    cores         = var.public_resources.cores
    memory        = var.public_resources.memory
    core_fraction = var.public_resources.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id    = data.yandex_compute_image.ubuntu.image_id
      type        = "network-hdd"
      size        = "50"
    }
  }

  network_interface {
    
    subnet_id  = yandex_vpc_subnet.subnet-b.id
    nat        = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "yandex_compute_instance" "worker2" {  
  name                      = local.instance_worker2
  zone                      = var.zone_d
  hostname                  = local.instance_worker2
  allow_stopping_for_update = true
  platform_id = "standard-v2"

 
  scheduling_policy {
  preemptible = true  // Прерываемая ВМ
  }

  resources {
    cores         = var.public_resources.cores
    memory        = var.public_resources.memory
    core_fraction = var.public_resources.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id    = data.yandex_compute_image.ubuntu.image_id
      type        = "network-hdd"
      size        = "50"
    }
  }

  network_interface {
    
    subnet_id  = yandex_vpc_subnet.subnet-d.id
    nat        = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "yandex_compute_instance" "jenkins" {  
  name                      = local.instance_jenkins
  zone                      = var.zone_a
  hostname                  = local.instance_jenkins
  allow_stopping_for_update = true
  platform_id = "standard-v2"

  scheduling_policy {
  preemptible = true  // Прерываемая ВМ
  }

  resources {
    cores         = var.public_resources.cores
    memory        = var.public_resources.memory
    core_fraction = var.public_resources.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id    = data.yandex_compute_image.ubuntu.image_id
      type        = "network-hdd"
      size        = "50"
    }
  }

  network_interface {
    
    subnet_id  = yandex_vpc_subnet.subnet-a.id
    nat        = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

  provisioner "local-exec" {
    command = "sleep 15"  
  }

  provisioner "file" {
    source      = "./jenkins-install.sh"
    destination = "/home/ubuntu/jenkins-install.sh"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host        = self.network_interface[0].nat_ip_address
    }
  }

  provisioner "remote-exec" {
    
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host        = self.network_interface[0].nat_ip_address
    }

    inline = [
      "sudo chmod +x /home/ubuntu/jenkins-install.sh",
      "sudo sh /home/ubuntu/jenkins-install.sh"
    ]
  }
}
