# Create service account
resource "yandex_iam_service_account" "bucket-sa" {
  name        = "bucket-sa"
  description = "service account for bucket"
}

# Grant permissions
resource "yandex_resourcemanager_folder_iam_member" "bucket-admin" {
  folder_id  = var.folder_id
  role       = "storage.admin"
  member     = "serviceAccount:${yandex_iam_service_account.bucket-sa.id}"
  depends_on = [yandex_iam_service_account.bucket-sa]
}


# Create Static Access Keys
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.bucket-sa.id
  description        = "static access key for object storage"
}

# Create bucket
resource "yandex_storage_bucket" "vp-bucket" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = "sasha-vp-bucket-2024"
  acl        = "public-read"
}

resource "yandex_storage_object" "object-1" {
    access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
    secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
    bucket = yandex_storage_bucket.vp-bucket.bucket
    key = "terraform.tfstate"
    source = "/home/zag1988/diplom/terraform2/terraform.tfstate"
    acl    = "private"
    depends_on = [yandex_storage_bucket.vp-bucket]
}
# 

