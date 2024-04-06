output "master_internal_ipv4" {
  value = yandex_compute_instance.master.network_interface[0].ip_address
}
output "worker1_internal_ipv4" {
  value = yandex_compute_instance.worker1.network_interface[0].ip_address
}
output "worker2_internal_ipv4" {
  value = yandex_compute_instance.worker2.network_interface[0].ip_address
}

output "master_external_ipv4" {
  value = yandex_compute_instance.master.network_interface[0].nat_ip_address
}
output "worker1_external_ipv4" {
  value = yandex_compute_instance.worker1.network_interface[0].nat_ip_address
}
output "worker2_external_ipv4" {
  value = yandex_compute_instance.worker2.network_interface[0].nat_ip_address
}
output "Jenkins_URL" {
  value = "http://${yandex_compute_instance.jenkins.network_interface[0].nat_ip_address}:8080"
}
output "bucket_domain_name" {
  value = "http://${yandex_storage_bucket.vp-bucket.bucket_domain_name}"
}