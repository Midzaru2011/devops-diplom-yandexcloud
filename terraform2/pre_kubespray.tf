resource "local_file" "k8s-kubespray" {
  content = <<EOF
all:
  hosts:
    master:
      ansible_host: ${yandex_compute_instance.master.network_interface[0].nat_ip_address}
      ip: ${yandex_compute_instance.master.network_interface[0].ip_address}
      access_ip: ${yandex_compute_instance.master.network_interface[0].ip_address}
      ansible_user: ubuntu
    node1:
      ansible_host: ${yandex_compute_instance.worker1.network_interface[0].nat_ip_address}
      ip: ${yandex_compute_instance.worker1.network_interface[0].ip_address}
      access_ip: ${yandex_compute_instance.worker1.network_interface[0].ip_address}
      ansible_user: ubuntu
    node2:
      ansible_host: ${yandex_compute_instance.worker2.network_interface[0].nat_ip_address}
      ip: ${yandex_compute_instance.worker2.network_interface[0].ip_address}
      access_ip: ${yandex_compute_instance.worker2.network_interface[0].ip_address}
      ansible_user: ubuntu
  children:
    kube_control_plane:
      hosts:
        master:
    kube_node:
      hosts:
        node1:
        node2:
    etcd:
      hosts:
        master:
    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
    calico_rr:
      hosts: {}  
      EOF
  filename = "${path.module}/hosts.yaml"
}
