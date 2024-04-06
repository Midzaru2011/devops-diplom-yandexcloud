terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">=0.13"

  # backend "s3" {
  #   endpoints = 
        #s3 = "https://storage.yandexcloud.net"
  #   region                      = "ru-central1"
  #   bucket                      = "vp-bucket"
  #   key                         = "tfstate"
  #   skip_region_validation      = true
  #   skip_credentials_validation = true
  # }
}

provider "yandex" {
  service_account_key_file = "/home/zag1988/lan/key.json"
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
}
