resource "local_file" "inventory_for_k8s_cluster" {
  content = <<-DOC
all:
  hosts:
    node0:
      ansible_host: ${yandex_compute_instance.cluster.0.network_interface[0].nat_ip_address}
      ip: ${yandex_compute_instance.cluster.0.network_interface[0].ip_address}
      access_ip: ${yandex_compute_instance.cluster.0.network_interface[0].ip_address}
      ansible_user: ubuntu
      # ansible_ssh_common_args: "-i /root/.ssh/new.rsa"
    node1:
      ansible_host: ${yandex_compute_instance.cluster.1.network_interface[0].nat_ip_address}
      ip: ${yandex_compute_instance.cluster.1.network_interface[0].ip_address}
      access_ip: ${yandex_compute_instance.cluster.1.network_interface[0].ip_address}
      ansible_user: ubuntu
    node2:
      ansible_host: ${yandex_compute_instance.cluster.2.network_interface[0].nat_ip_address}
      ip: ${yandex_compute_instance.cluster.2.network_interface[0].ip_address}
      access_ip: ${yandex_compute_instance.cluster.2.network_interface[0].ip_address}
      ansible_user: ubuntu
  children:
    kube_control_plane:
      hosts:
        node0:
    kube_node:
      hosts:
        node1:
        node2:
    etcd:
      hosts:
        node0:
    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
    calico_rr:
      hosts: {}  
      DOC
  filename = "/home/zag1988/kubespray/inventory/mycluster/hosts.yaml"
}
