# Дипломный практикум в Yandex.Cloud

* [Цели:](#цели)
* [Этапы выполнения:](#этапы-выполнения)
  * [Создание облачной инфраструктуры](#создание-облачной-инфраструктуры)
  * [Создание Kubernetes кластера](#создание-kubernetes-кластера)
  * [Создание тестового приложения](#создание-тестового-приложения)
  * [Подготовка cистемы мониторинга и деплой приложения](#подготовка-cистемы-мониторинга-и-деплой-приложения)
  * [Установка и настройка CI/CD](#установка-и-настройка-cicd)
* [Что необходимо для сдачи задания?](#что-необходимо-для-сдачи-задания)
* [Как правильно задавать вопросы дипломному руководителю?](#как-правильно-задавать-вопросы-дипломному-руководителю)

**Перед началом работы над дипломным заданием изучите [Инструкция по экономии облачных ресурсов](https://github.com/netology-code/devops-materials/blob/master/cloudwork.MD).**

---

## Цели

1. Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
2. Запустить и сконфигурировать Kubernetes кластер.
3. Установить и настроить систему мониторинга.
4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
5. Настроить CI для автоматической сборки и тестирования.
6. Настроить CD для автоматического развёртывания приложения.

---

## Этапы выполнения

##  Создание облачной инфраструктуры

<details><summary> Задание №1 </summary>

Для начала необходимо подготовить облачную инфраструктуру в ЯО при помощи [Terraform](https://www.terraform.io/).

Особенности выполнения:

* Бюджет купона ограничен, что следует иметь в виду при проектировании инфраструктуры и использовании ресурсов;
Для облачного k8s используйте региональный мастер(неотказоустойчивый). Для self-hosted k8s минимизируйте ресурсы ВМ и долю ЦПУ. В обоих вариантах используйте прерываемые ВМ для worker nodes.
* Следует использовать версию [Terraform](https://www.terraform.io/) не старше 1.5.x .

Предварительная подготовка к установке и запуску Kubernetes кластера.

1. Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя
2. Подготовьте [backend](https://www.terraform.io/docs/language/settings/backends/index.html) для Terraform:  
   а. Рекомендуемый вариант: S3 bucket в созданном ЯО аккаунте(создание бакета через TF)
   б. Альтернативный вариант:  [Terraform Cloud](https://app.terraform.io/)  
3. Создайте VPC с подсетями в разных зонах доступности.
4. Убедитесь, что теперь вы можете выполнить команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.
5. В случае использования [Terraform Cloud](https://app.terraform.io/) в качестве [backend](https://www.terraform.io/docs/language/settings/backends/index.html) убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.

</details>

Ожидаемые результаты:

1. Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий.
2. Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.

---

## Решение

1. Для создания облачной инфрструктуры были созданы файлы конфигурации [Terraform](https://github.com/Midzaru2011/devops-diplom-yandexcloud/tree/main/terraform2).  
Для управлением облачной инфраструктурой, был создан сервисный аккаунт:

```shell
zag1988@mytest6:~/devops-diplom-yandexcloud/terraform2$ yc iam service-account list
+----------------------+-------------+
|          ID          |    NAME     |
+----------------------+-------------+
| aje78fj1njr9ki9jaem4 | terraform   |
| ajen2m037tokpdof7lp1 | midzaru2011 |
+----------------------+-------------+

```

2. Установленная версия terraform:

```shell
zag1988@mytest6:~/devops-diplom-yandexcloud/terraform2$ terraform --version
Terraform v1.4.6
on linux_amd64
+ provider registry.terraform.io/hashicorp/local v2.5.1
+ provider registry.terraform.io/yandex-cloud/yandex v0.116.0

Your version of Terraform is out of date! The latest version
is 1.8.1. You can update by downloading from https://www.terraform.io/downloads.html
```

3. Конфигурация terraform для создания требуемой архитектуры [terraform2](terraform2):
   В данной конфигурации создаются:
   * _VPC c подсетями разных зонах доступности:_

![VPC](IMG/VPC.PNG)
   * _Создается bucket, куда отправляется файл terraform.tfstate, который используется в качестве backend:_

![Bucket](<IMG/bucket for backend.PNG>)

4. Также были созданы четыре виртуальные машины, которые будут использованы в дальнейшем для установки кластера k8s и jenkins:

```shell
zag1988@compute-vm-4-4-70-hdd-1725199716918:~$ yc compute instance list
+----------------------+-------------------------------------+---------------+---------+----------------+-------------+
|          ID          |                NAME                 |    ZONE ID    | STATUS  |  EXTERNAL IP   | INTERNAL IP |
+----------------------+-------------------------------------+---------------+---------+----------------+-------------+
| epd46igg0o68omfjj6ap | node-1                              | ru-central1-b | RUNNING | 84.252.139.108 | 10.10.2.24  |
| fhm0u2e6lshfe0pkci5d | node-0                              | ru-central1-a | RUNNING | 89.169.152.199 | 10.10.1.31  |
| fhm638ghmkm6mkhtmlb3 | compute-vm-4-4-70-hdd-1725199716918 | ru-central1-a | RUNNING | 62.84.127.224  | 10.128.0.28 |
| fhmjqjl6dtkb38of7mf5 | jenkins                             | ru-central1-a | RUNNING | 89.169.150.99  | 10.10.1.24  |
| fv4gotoa0gd38s9rduhk | node-2                              | ru-central1-d | RUNNING | 51.250.36.147  | 10.10.3.33  |
+----------------------+-------------------------------------+---------------+---------+----------------+-------------+
```

## Создание Kubernetes кластера

<details><summary>Задание №2 </summary>

На этом этапе необходимо создать [Kubernetes](https://kubernetes.io/ru/docs/concepts/overview/what-is-kubernetes/) кластер на базе предварительно созданной инфраструктуры.   Требуется обеспечить доступ к ресурсам из Интернета.

Это можно сделать двумя способами:

1. Рекомендуемый вариант: самостоятельная установка Kubernetes кластера.  
   а. При помощи Terraform подготовить как минимум 3 виртуальных машины Compute Cloud для создания Kubernetes-кластера. Тип виртуальной машины следует выбрать самостоятельно с учётом требовании к производительности и стоимости. Если в дальнейшем поймете, что необходимо сменить тип инстанса, используйте Terraform для внесения изменений.  
   б. Подготовить [ansible](https://www.ansible.com/) конфигурации, можно воспользоваться, например [Kubespray](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/)  
   в. Задеплоить Kubernetes на подготовленные ранее инстансы, в случае нехватки каких-либо ресурсов вы всегда можете создать их при помощи Terraform.
2. Альтернативный вариант: воспользуйтесь сервисом [Yandex Managed Service for Kubernetes](https://cloud.yandex.ru/services/managed-kubernetes)  
  а. С помощью terraform resource для [kubernetes](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_cluster) создать **региональный** мастер kubernetes с размещением нод в разных 3 подсетях
  б. С помощью terraform resource для [kubernetes node group](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_node_group)

</details>

Ожидаемый результат:

1. Работоспособный Kubernetes кластер.
2. В файле `~/.kube/config` находятся данные для доступа к кластеру.
3. Команда `kubectl get pods --all-namespaces` отрабатывает без ошибок.

---

## Решение

1. Для установки кластера  k8s воспользовался отредактированной конфигурацией ansible из [Kubespray](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/):
   * При развертывании инфраструктуры через terraform, для использования ansible, прокинули публичные ключи [main.tf](terraform2/main.tf);
   * Склонировал репозиторий Kubespray: **git clone <https://github.com/kubernetes-sigs/kubespray.git>** на локальную машину;
   * Переименовал каталог с inventory: **cd kubespray/ &&  cp -rfp inventory/sample inventory/mycluster**;
   * Установил необходимые зависимости для выполнения playbook kubespray из requirements: **pip install -U -r requirements.txt**
   * Заменил inventory файл host.ymal в каталоге ~/kubespray/inventory/mycluster/group_vars/ на динамически сгененированный terraform [pre_kubespray](terraform2/pre_kubespray.tf) на [hosts.yaml](kubespray/inventory/mycluster/hosts.yaml);
   * Для того, чтобы кластер k8s был доступен из интернета, в конфигах изменил параметр supplementary_addresses_in_ssl_keys [supplementary_addresses_in_ssl_keys](kubespray/mycluster/group_vars/k8s_cluster/k8s-cluster.yml) на EXTERNAL IP  node-0, которая будет выступать мастер нодой;  
   * Запустил playbook для установки кластера k8s: **ansible-playbook -i inventory/mycluster/hosts.yaml  --become --become-user=root cluster.yml**;
   * Playbook успешно завершился:

![PLAY RECAP](<IMG/kuberspray.PNG>)
   * Проверил, что кластер доступен по внешнему адресу, который задавали в конфигах:

![alt text](<IMG/external IP.PNG>)
   * заходим на мастер ноду кластера, и проверяем доступность конфигурационных файлов и созданных pods:

<details><summary>cat ~/.kube/config </summary>

```shell
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJRUJpTEp3bVNaZGd3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TkRBNU1ERXhORFV5TWpsYUZ3MHpOREE0TXpBeE5EVTNNamxhTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUURtVldBdDFjSlVPMWloVUV2Z3ozdkt1c0lnOUdtZnhOUnFXZ3FGQTRyR0tCcEZ1cXNVbzNqVEhxMmsKUTBNSThkaW5zQ3JGT29iVWFKbkg1K0g0am9BUFY2NDRMVHo1bzJKZCtNYi9xOGtZZkdEbjE2VnpmQnBzOHBHYwpKS2d3QXR2aHRzamRiYklxKy9KTXVwTnh4d2pNNlE2cG1DamhzL05ra2NsUDJhZ254RWhxeWxNdkJUNFY0V21OCjI0bElnYjNFMDE4d0NDbU5ObVJEdjVLeEQ2QWJCSDVMNFFwM0ZxN3dzRnJOeFR6R1F0S3VmRDBBcGlpb29MVXoKaW1iU0xIL2QwSEI4T1YyL0F1M2c4eEJ4d05xK3k2anZ4eHBzckN0VEtnQ1JqaWhtQU5nT2RTQ3VJSGo5VUY2UwpxZmdrKzUxaE93SnVOdGNtRlN4YkFneW8ybHVIQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJUVk9iN1lwc281UEgvcTFQTFVoTGN5UlVqZy96QVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRRGtpencvcHl5dApYQk1DTWpFTi90c1JWQitFRGd0eVJyMzFhWjdkMXMzVzBFK1ZxdXpTNzZKMDRoRWdiRm05VHFYMjVkYS8zSlJoCmpCV2cwRXBDai8xZWwxcFk0bmFOTUtWdnZ2NzhnYVc1emt4bUp5YW9razR5dWVGU1ptQm1XWTRuWFhxNFM0dFcKcTN0MnI5ODhJSGRmN2tFaER0RWJsV2NROHR1bEE3UkF2eURYemhtckdIaWtHZmVmdDJNbklmSlVIbldmQ3YrZQpFbXFmazdTMzhLNlBWTjdDd0daeTlPR28rcEk0SE40aWpLUkR3V3ZjSEpISGkxYXNUQ0hHQzJGTDFoMDFRMFhQCmVxKzhxRi81V0l0L3pWekhMR0pBYXNPcUxGYStBdjhBUFVkN3JwS3VURERRVmlheFIxTER0cDQxakhLSGNmNWIKbGxKbkpnMEdPVW1KCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
    server: https://89.169.152.199:6443
  name: cluster.local
contexts:
- context:
    cluster: cluster.local
    user: kubernetes-admin
  name: kubernetes-admin@cluster.local
current-context: kubernetes-admin@cluster.local
kind: Config
preferences: {}
users:
- name: kubernetes-admin
  user:
    client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURJVENDQWdtZ0F3SUJBZ0lJVGovYWthK21Xb1F3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TkRBNU1ERXhORFV5TWpsYUZ3MHlOVEE1TURFeE5EVTNNekJhTURReApGekFWQmdOVkJBb1REbk41YzNSbGJUcHRZWE4wWlhKek1Sa3dGd1lEVlFRREV4QnJkV0psY201bGRHVnpMV0ZrCmJXbHVNSUlCSWpBTkJna3Foa2lHOXcwQkFRRUZBQU9DQVE4QU1JSUJDZ0tDQVFFQStuTzlCMHJHOFFHaGszOW0KdGYyV3ZRMU5CeHhtZ05seC9VMjhHb3RtVm85OXpUSHliQTJRbEduRTN4QlUyTHVGYnZZNm8rN3lVUjZZRWVlaQpQb1hqL0d0RE95cENHWU1vS3VrdU1keXN2b0NyelI1Z21INFA1QXlGTHJ4emd2WVdYSDlnTDN5SlU2aXFCRGhUCkNqN3RZUGRKMVF3c3ZVZTczbm0vWHRQOUtydElYZjljTjR1QUVFeXJucnNxWGlRQmRpQXhrT0xhOXMwemw1RWUKY0k0R0V0c2pzZGdJYTRFeHdjeDV3b0FFWFJTdkpoY3l5ZWdRZzltOGdWTmFUdTlUTThyODFqeWNubGcxMUlTZQoySmZTOVNpbHRrWXVaWFBmUHR0bDByaDVzN3RvZ0tmaFhYNlVUN3h5VXNvOG0rNFozZFdUNUZrZ2NZRHk4MlBKCklPQVZqUUlEQVFBQm8xWXdWREFPQmdOVkhROEJBZjhFQkFNQ0JhQXdFd1lEVlIwbEJBd3dDZ1lJS3dZQkJRVUgKQXdJd0RBWURWUjBUQVFIL0JBSXdBREFmQmdOVkhTTUVHREFXZ0JUVk9iN1lwc281UEgvcTFQTFVoTGN5UlVqZwovekFOQmdrcWhraUc5dzBCQVFzRkFBT0NBUUVBUUdQbkhWeVhaU29LUG82OXdZL3IwU1VkODRrSm8wUkhKZUFrCnhkU0tWeWJOcENuVTlVUEZDd0FGayt5WkpERHR2ZDVnRDlRSEVVS2VqNnhnZGwzQWM2elF1WnJYTXJnS3Z5M0sKbFFsT2I1ZlVhaEVYQW1qMlZjck5YUUFtMmhrbkQzV1hNOFl2azQrL2VneEhrcURHQ3pxcVp5QWUzOVFWQWZQSApTd0lOVGhSM05vOWN6Y0ZoclBnSm8vaUtjLzJsN0llTFhBUEpoSFRveHR0ZWtpTUxTalJDejErZFpVQ0gxVHZTCnlhS2FQaW9venZPT2hNdi80dXFnQWNTQzNsZE1Zd25xTFlLRXNSYXkybWJWcldpL0x0dGlsNS9FRWVYak5NNnEKRDZXWGtCVVNUUUJpYlFpSDdiVE9uZXRoMW40Ym4rU2JyVDRPclFRKzJRbC9VZmlDTnc9PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
    client-key-data: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFcFFJQkFBS0NBUUVBK25POUIwckc4UUdoazM5bXRmMld2UTFOQnh4bWdObHgvVTI4R290bVZvOTl6VEh5CmJBMlFsR25FM3hCVTJMdUZidlk2bys3eVVSNllFZWVpUG9Yai9HdERPeXBDR1lNb0t1a3VNZHlzdm9DcnpSNWcKbUg0UDVBeUZMcnh6Z3ZZV1hIOWdMM3lKVTZpcUJEaFRDajd0WVBkSjFRd3N2VWU3M25tL1h0UDlLcnRJWGY5YwpONHVBRUV5cm5yc3FYaVFCZGlBeGtPTGE5czB6bDVFZWNJNEdFdHNqc2RnSWE0RXh3Y3g1d29BRVhSU3ZKaGN5CnllZ1FnOW04Z1ZOYVR1OVRNOHI4MWp5Y25sZzExSVNlMkpmUzlTaWx0a1l1WlhQZlB0dGwwcmg1czd0b2dLZmgKWFg2VVQ3eHlVc284bSs0WjNkV1Q1RmtnY1lEeTgyUEpJT0FWalFJREFRQUJBb0lCQUNGN0FXVU5LUVVrMjYyMQpGVXowNW9iRlZXdkM3eTBBWkkyaEs2azh3MlNFOENOVEx2NGszaFFKQTZseUxIV0FzL2krYjk1a1hmNWNJYVliCkdnUlRyOE9acnpZa2t3dUlEZ0dXaEhkajhhL1IwYVd0RHVxengzb0w5bTNtQVdjYmNLZlMyMC9kelJuaTdUOTkKTEJTdGp0d3NrckVwWEgyOUxpOHloVk91OFNRWis0SFBJRUg2VExaVDI0Y3Z6NTg0ampGRXE0WWlnR2hCV3RQMwpiL0YyMkJkcnVhSUwxMnh3Tk84UXU3d1ZReDJ3cW40dzhOYlRQZG5MdG5LbkppY3JlU05WN1NDZGU0SHp0Tm1ZCkwrSVdWWXRPWUtsTHBqdmE0N0MvYkJmK1pmUkhoeTZpTWdXMHQxcytyaUlLcGVmcEkzais0Zi9NWUlXazBKTFMKQllMbnFyMENnWUVBK3U0dzZseXh1emZNOU91NUV1NmNYcTZnVE1lNFYreW56T0VhK0FMa2gyUnBLZ1dNcFVVdwp3alR3VTJlSS9oY2pYd2xxVjdlSzdyU1JUQ0d4bW9QUW1abktGTWVyNGFpR1pjbHhLV216WjF1YklvSWg4UlJHCkhVamZzKzhxM0daSDFHL3dzN1BnV1Y5S0daRmxBWmp5QXRCMDVKVVNRMlZHMGJuby85SFlOTk1DZ1lFQS80TVMKeWhGNS9sVklXRi9kdnpmamxKVlZDSTZxZ3JtdUY0UWJaT2VMNzlDcTdKNUJPKzE5eG1LbGJRUUJUZVRTQXpWRQpJUURGVC9LWURyVlJYcGpYdGQzd2FhSXl3UDhFaTRxMXJTMTltcjRyRWVXQUY5QUZXKzhOL2RJUW8rcHdTczRVCi9HWmNQNnlSQzlyL3VHakpqb2ZVZkVWY0wxeHRZRU44SHUwNWtCOENnWUVBN24yVVlDclpnV2IzbFpDMHhobWkKNVJwem9JWHgzeDgrSEt1V1JrSDVrZlVOUHJNbmlhekpPc3UxM285NDFJYUpSN3BiS0NONkdJWGwwc1h6VnpnUQordXYvOU9BUnJOZlBaTTZnand1M1IzVDViVUxobjQvMVU3Ly9YYlRpdDdjK2JkbzJtNVZLbGFiTGRxR0pyb3IrCitVM0d5N29qTVlzQVZEU3VEdllTMTZFQ2dZRUFudDZ6MXhxSXZOL3dES3NHNkxkcWROOXBNTm5zSVQ0c2hnaXAKTTlOWXlqTDNwQW8rUzNHK2E1UzRnUkVsY25aZE1vdHpJZ1lscVRFUTVNeE9uTC95RisyNFp5WG40dUp0eEFucQpMcFNEYmF6aWdNMHZHUjlKeGNEYzlUNGhCSnBuV2N2TGRxaDZvVWkrSXgzM05JVkxGYWxWTURPOFB1SjhTNGVLCmJIeFo5MGNDZ1lFQTVxa2JrZjhITjNNaHB3UkJTMDdwTVZlODJRRXFXc1NzREFBTXlzMzZvUG0yQVRoUkpVTVEKWjI1UWZLcHVxWDBQNnJvNHZ2RURpNWJkTHpWRFhpLzVOV20rM25pbUU5SHBtempOVXpFSzhlaTJ1MmNVOGhrTwp6OW40Mm13SlJ4clk1cDJ2WmxEREhSd2xrVFR4d2JhMXB3VGtlbEFiMVpSVlNKZjNhKzM0Y3BRPQotLS0tLUVORCBSU0EgUFJJVkFURSBLRVktLS0tLQo=
```

</details>

<details><summary>sudo kubectl get pods --all-namespaces </summary>

```shell
ubuntu@node0:~$ sudo kubectl get pods --all-namespaces
NAMESPACE     NAME                                                READY   STATUS    RESTARTS   AGE
argocd        argocd-application-controller-0                     1/1     Running   0          22m
argocd        argocd-applicationset-controller-568754c579-st6t6   1/1     Running   0          22m
argocd        argocd-dex-server-7658dcdf77-qjt7k                  1/1     Running   0          22m
argocd        argocd-notifications-controller-5548b96954-flc8w    1/1     Running   0          22m
argocd        argocd-redis-6976fc7dfc-bbxx5                       1/1     Running   0          22m
argocd        argocd-repo-server-7594f8849c-dztdz                 1/1     Running   0          22m
argocd        argocd-server-58cc545d87-xb7gm                      1/1     Running   0          22m
kube-system   calico-kube-controllers-648dffd99-v5hl4             1/1     Running   0          23m
kube-system   calico-node-bm4cc                                   1/1     Running   0          24m
kube-system   calico-node-bm5qt                                   1/1     Running   0          24m
kube-system   calico-node-wtph5                                   1/1     Running   0          24m
kube-system   coredns-77f7cc69db-4gj8x                            1/1     Running   0          23m
kube-system   coredns-77f7cc69db-8xrf2                            1/1     Running   0          23m
kube-system   dns-autoscaler-8576bb9f5b-9j6ds                     1/1     Running   0          23m
kube-system   kube-apiserver-node0                                1/1     Running   1          25m
kube-system   kube-controller-manager-node0                       1/1     Running   2          25m
kube-system   kube-proxy-4rpcv                                    1/1     Running   0          24m
kube-system   kube-proxy-5v8v8                                    1/1     Running   0          24m
kube-system   kube-proxy-jjc5q                                    1/1     Running   0          24m
kube-system   kube-scheduler-node0                                1/1     Running   1          25m
kube-system   nginx-proxy-node1                                   1/1     Running   0          24m
kube-system   nginx-proxy-node2                                   1/1     Running   0          24m
kube-system   nodelocaldns-4hd6l                                  1/1     Running   0          23m
kube-system   nodelocaldns-8j756                                  1/1     Running   0          23m
kube-system   nodelocaldns-tz8xk                                  1/1     Running   0          23m
```

</details>

<details><summary>sudo kubectl get nodes </summary>

```shell
ubuntu@node0:~$ sudo kubectl get nodes
NAME    STATUS   ROLES           AGE   VERSION
node0   Ready    control-plane   25m   v1.28.6
node1   Ready    <none>          25m   v1.28.6
node2   Ready    <none>          25m   v1.28.6

```

</details>

# Создание тестового приложения

<details><summary>Задание №3</summary>
Для перехода к следующему этапу необходимо подготовить тестовое приложение, эмулирующее основное приложение разрабатываемое вашей компанией.
+
Способ подготовки:

1. Рекомендуемый вариант:  
   а. Создайте отдельный git репозиторий с простым nginx конфигом, который будет отдавать статические данные.  
   б. Подготовьте Dockerfile для создания образа приложения.  
2. Альтернативный вариант:  
   а. Используйте любой другой код, главное, чтобы был самостоятельно создан Dockerfile.

## </details>

Ожидаемый результат:

1. Git репозиторий с тестовым приложением и Dockerfile.
2. Регистри с собранным docker image. В качестве регистри может быть DockerHub или [Yandex Container Registry](https://cloud.yandex.ru/services/container-registry), созданный также с помощью terraform.

---

## Решение

1. В отдельном репозитории подготовил стартовую страницу для приложение [Index.html](https://github.com/Midzaru2011/myapp/blob/main/index.html)
2. В этом же репозитории разметистил Dockerfile для создания образа приложени [Dockerfile](https://github.com/Midzaru2011/myapp/blob/main/Dockerfile)
3. Для проверки правильности созданых инструкций, запустил сборку образа:

   <details><summary>docker build -t midzaru2011/myapp:1.0.1 .</summary>

   ```shell
   zag1988@compute-vm-4-4-70-hdd-1725199716918:~/myapp$ docker build -t midzaru2011/myapp:1.0.1 .
   [+] Building 4.9s (9/9) FINISHED                                                                                                                              docker:default
   => [internal] load build definition from Dockerfile                                                                                                                    0.7s
   => => transferring dockerfile: 125B                                                                                                                                    0.0s
   => [internal] load .dockerignore                                                                                                                                       0.7s
   => => transferring context: 2B                                                                                                                                         0.0s
   => [internal] load metadata for docker.io/library/nginx:latest                                                                                                         2.7s
   => [auth] library/nginx:pull token for registry-1.docker.io                                                                                                            0.0s
   => [1/3] FROM docker.io/library/nginx:latest@sha256:447a8665cc1dab95b1ca778e162215839ccbb9189104c79d7ec3a81e14577add                                                   0.1s
   => [internal] load build context                                                                                                                                       0.1s
   => => transferring context: 454B                                                                                                                                       0.0s
   => CACHED [2/3] WORKDIR /usr/share/nginx/html                                                                                                                          0.0s
   => [3/3] COPY index.html /usr/share/nginx/html/                                                                                                                        0.9s
   => exporting to image                                                                                                                                                  0.1s
   => => exporting layers                                                                                                                                                 0.1s
   => => writing image sha256:d0e6d2c71772a3b05c87b5ad69628f03c250484b290149c6b1f2c8de0d1f539a                                                                            0.0s
   => => naming to docker.io/midzaru2011/myapp:1.0.1
   
   zag1988@compute-vm-4-4-70-hdd-1725199716918:~/myapp$ docker images midzaru2011/myapp
   REPOSITORY          TAG       IMAGE ID       CREATED         SIZE
   midzaru2011/myapp   1.0.1     d0e6d2c71772   7 minutes ago   188MB

   ```
4. Для проверки работы приложения, запустил контейнер из созданого образа: 

   <details><summary> docker run -d -p 8081:80 midzaru2011/myapp:1.0.1</summary>

   ```shell
   zag1988@compute-vm-4-4-70-hdd-1725199716918:~/myapp$ docker run -d -p 8081:80 midzaru2011/myapp:1.0.1
   46e16c80b5933c2f87b0890255afef865ba2b30569c4228f67eb1d57ef50f2cd
   ```
   </details>

5. Приложение отвечает по указанному порту:

   <details><summary>curl</summary>

   ```shell
   zag1988@compute-vm-4-4-70-hdd-1725199716918:~/myapp$ curl -v http://62.84.127.224:8081/
   *   Trying 62.84.127.224:8081...
   * Connected to 62.84.127.224 (62.84.127.224) port 8081 (#0)
   > GET / HTTP/1.1
   > Host: 62.84.127.224:8081
   > User-Agent: curl/7.81.0
   > Accept: */*
   > 
   * Mark bundle as not supporting multiuse
   < HTTP/1.1 200 OK
   < Server: nginx/1.27.1
   < Date: Sun, 01 Sep 2024 16:10:12 GMT
   < Content-Type: text/html
   < Content-Length: 415
   < Last-Modified: Sun, 01 Sep 2024 15:43:22 GMT
   < Connection: keep-alive
   < ETag: "66d48b9a-19f"
   < Accept-Ranges: bytes
   < 
   <!DOCTYPE html>
   <html lang="ru"> 

   <head>
      <meta charset="utf-8" name="viewport" content="width=device-width, initial-scale=1" />
      <title>I’m DevOps Engineer! Zaitsev Alexander!</title>
   </head>

   <body>
      <h2 style="margin-top: 150px; text-align: center;">Дипломный проект!</h2>
      <h4>Подготовил: Зайцев Александр! </h4>
      <h4>version 1.0.1</h4>
   </body>
   </html>
   * Connection #0 to host 62.84.127.224 left intact
   ```
   </details>
6. Для дальнейшего использования данного образа, загрузил его в DockerHub:

   <details><summary>docker push midzaru2011/myapp:1.0.1 </summary>
      
   ```shell
   zag1988@compute-vm-4-4-70-hdd-1725199716918:~/myapp$ docker push midzaru2011/myapp:1.0.1 
   The push refers to repository [docker.io/midzaru2011/myapp]
   cb91e93b488d: Pushed 
   5f70bf18a086: Mounted from midzaru2011/app 
   5f0272c6e96d: Layer already exists 
   f4f00eaedec7: Layer already exists 
   55e54df86207: Layer already exists 
   ec1a2ca4ac87: Layer already exists 
   8b87c0c66524: Layer already exists 
   72db5db515fd: Layer already exists 
   9853575bc4f9: Layer already exists 
   1.0.1: digest: sha256:03f83431b23322f39f87fceec32c4594507c1298687a85e15203e41e2af80684 size: 2191
   ```
      </details>
6. Проверил, что докер образ успешно был создан в docker registry:

![DockerHub](IMG/DockerHub.PNG)


## Подготовка cистемы мониторинга и деплой приложения

<details><summary>Задание №4</summary>

Уже должны быть готовы конфигурации для автоматического создания облачной инфраструктуры и поднятия Kubernetes кластера.  
Теперь необходимо подготовить конфигурационные файлы для настройки нашего Kubernetes кластера.

Цель:

1. Задеплоить в кластер [prometheus](https://prometheus.io/), [grafana](https://grafana.com/), [alertmanager](https://github.com/prometheus/alertmanager), [экспортер](https://github.com/prometheus/node_exporter) основных метрик Kubernetes.
2. Задеплоить тестовое приложение, например, [nginx](https://www.nginx.com/) сервер отдающий статическую страницу.

Способ выполнения:

1. Воспользовать пакетом [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus), который уже включает в себя [Kubernetes оператор](https://operatorhub.io/) для [grafana](https://grafana.com/), [prometheus](https://prometheus.io/), [alertmanager](https://github.com/prometheus/alertmanager) и [node_exporter](https://github.com/prometheus/node_exporter). При желании можете собрать все эти приложения отдельно.
2. Для организации конфигурации использовать [qbec](https://qbec.io/), основанный на [jsonnet](https://jsonnet.org/). Обратите внимание на имеющиеся функции для интеграции helm конфигов и [helm charts](https://helm.sh/)
3. Если на первом этапе вы не воспользовались [Terraform Cloud](https://app.terraform.io/), то задеплойте и настройте в кластере [atlantis](https://www.runatlantis.io/) для отслеживания изменений инфраструктуры. Альтернативный вариант 3 задания: вместо Terraform Cloud или atlantis настройте на автоматический запуск и применение конфигурации terraform из вашего git-репозитория в выбранной вами CI-CD системе при любом комите в main ветку. Предоставьте скриншоты работы пайплайна из CI/CD системы.

</details>

Ожидаемый результат:

1. Git репозиторий с конфигурационными файлами для настройки Kubernetes.
2. Http доступ к web интерфейсу grafana.
3. Дашборды в grafana отображающие состояние Kubernetes кластера.
4. Http доступ к тестовому приложению.

---

## Решение

Для настройки систмемы мониторинга, воспользовался Helm Charts [Prometheus Community](https://prometheus-community.github.io/helm-charts), пердварительно настроив Kubernetes кластер.

1. Создал новое пространство имен для мониоринга:
   
```shell
ubuntu@node0:~$ kubectl create ns monitoring
namespace/monitoring created
```
2. Добавил репозиторий чартов для системы мониторинга:

```shell
ubuntu@node0:~$ helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
"prometheus-community" has been added to your repositories
ubuntu@node0:~$ helm repo list
NAME                    URL                                               
prometheus-community    https://prometheus-community.github.io/helm-charts
```

3. Проверил доступные charts:

   <details><summary>helm search repo prometheus-community</summary>

   ```shell
   ubuntu@node0:~$ helm search repo prometheus-community
   NAME                                                    CHART VERSION   APP VERSION     DESCRIPTION                                       
   prometheus-community/alertmanager                       1.12.0          v0.27.0         The Alertmanager handles alerts sent by client ...
   prometheus-community/alertmanager-snmp-notifier         0.3.0           v1.5.0          The SNMP Notifier handles alerts coming from Pr...
   prometheus-community/jiralert                           1.7.1           v1.3.0          A Helm chart for Kubernetes to install jiralert   
   prometheus-community/kube-prometheus-stack              62.3.1          v0.76.0         kube-prometheus-stack collects Kubernetes manif...
   prometheus-community/kube-state-metrics                 5.25.1          2.13.0          Install kube-state-metrics to generate and expo...
   prometheus-community/prom-label-proxy                   0.10.0          v0.11.0         A proxy that enforces a given label in a given ...
   prometheus-community/prometheus                         25.27.0         v2.54.1         Prometheus is a monitoring system and time seri...
   prometheus-community/prometheus-adapter                 4.11.0          v0.12.0         A Helm chart for k8s prometheus adapter           
   prometheus-community/prometheus-blackbox-exporter       9.0.0           v0.25.0         Prometheus Blackbox Exporter                      
   prometheus-community/prometheus-cloudwatch-expo...      0.25.3          0.15.5          A Helm chart for prometheus cloudwatch-exporter   
   prometheus-community/prometheus-conntrack-stats...      0.5.10          v0.4.18         A Helm chart for conntrack-stats-exporter         
   prometheus-community/prometheus-consul-exporter         1.0.0           0.4.0           A Helm chart for the Prometheus Consul Exporter   
   prometheus-community/prometheus-couchdb-exporter        1.0.0           1.0             A Helm chart to export the metrics from couchdb...
   prometheus-community/prometheus-druid-exporter          1.1.0           v0.11.0         Druid exporter to monitor druid metrics with Pr...
   prometheus-community/prometheus-elasticsearch-e...      6.4.0           v1.7.0          Elasticsearch stats exporter for Prometheus       
   prometheus-community/prometheus-fastly-exporter         0.4.0           v8.1.0          A Helm chart for the Prometheus Fastly Exporter   
   prometheus-community/prometheus-ipmi-exporter           0.4.0           v1.8.0          This is an IPMI exporter for Prometheus.          
   prometheus-community/prometheus-json-exporter           0.13.0          v0.6.0          Install prometheus-json-exporter                  
   prometheus-community/prometheus-kafka-exporter          2.10.0          v1.7.0          A Helm chart to export the metrics from Kafka i...
   prometheus-community/prometheus-memcached-exporter      0.3.4           v0.14.4         Prometheus exporter for Memcached metrics         
   prometheus-community/prometheus-modbus-exporter         0.1.2           0.4.1           A Helm chart for prometheus-modbus-exporter       
   prometheus-community/prometheus-mongodb-exporter        3.6.0           0.40.0          A Prometheus exporter for MongoDB metrics         
   prometheus-community/prometheus-mysql-exporter          2.6.1           v0.15.1         A Helm chart for prometheus mysql exporter with...
   prometheus-community/prometheus-nats-exporter           2.17.0          0.15.0          A Helm chart for prometheus-nats-exporter         
   prometheus-community/prometheus-nginx-exporter          0.2.1           0.11.0          A Helm chart for the Prometheus NGINX Exporter    
   prometheus-community/prometheus-node-exporter           4.39.0          1.8.2           A Helm chart for prometheus node-exporter         
   prometheus-community/prometheus-opencost-exporter       0.1.1           1.108.0         Prometheus OpenCost Exporter                      
   prometheus-community/prometheus-operator                9.3.2           0.38.1          DEPRECATED - This chart will be renamed. See ht...
   prometheus-community/prometheus-operator-admiss...      0.15.0          0.76.0          Prometheus Operator Admission Webhook             
   prometheus-community/prometheus-operator-crds           14.0.0          v0.76.0         A Helm chart that collects custom resource defi...
   prometheus-community/prometheus-pgbouncer-exporter      0.3.0           v0.8.0          A Helm chart for prometheus pgbouncer-exporter    
   prometheus-community/prometheus-pingdom-exporter        2.5.0           20190610-1      A Helm chart for Prometheus Pingdom Exporter      
   prometheus-community/prometheus-pingmesh-exporter       0.4.0           v1.2.1          Prometheus Pingmesh Exporter                      
   prometheus-community/prometheus-postgres-exporter       6.3.1           v0.15.0         A Helm chart for prometheus postgres-exporter     
   prometheus-community/prometheus-pushgateway             2.14.0          v1.9.0          A Helm chart for prometheus pushgateway           
   prometheus-community/prometheus-rabbitmq-exporter       1.12.1          v0.29.0         Rabbitmq metrics exporter for prometheus          
   prometheus-community/prometheus-redis-exporter          6.5.0           v1.62.0         Prometheus exporter for Redis metrics             
   prometheus-community/prometheus-smartctl-exporter       0.10.0          v0.12.0         A Helm chart for Kubernetes                       
   prometheus-community/prometheus-snmp-exporter           5.5.0           v0.26.0         Prometheus SNMP Exporter                          
   prometheus-community/prometheus-sql-exporter            0.1.0           v0.5.4          Prometheus SQL Exporter                           
   prometheus-community/prometheus-stackdriver-exp...      4.6.0           v0.16.0         Stackdriver exporter for Prometheus               
   prometheus-community/prometheus-statsd-exporter         0.14.0          v0.27.1         A Helm chart for prometheus stats-exporter        
   prometheus-community/prometheus-systemd-exporter        0.3.0           0.6.0           A Helm chart for prometheus systemd-exporter      
   prometheus-community/prometheus-to-sd                   0.4.2           0.5.2           Scrape metrics stored in prometheus format and ...
   prometheus-community/prometheus-windows-exporter        0.5.2           0.27.2          A Helm chart for prometheus windows-exporter   
   ```
   </details>

4. Запустил установку  prometheus и всех зависимостей через helm в созданном namespace:

```shell
ubuntu@node0:~$ helm install stable prometheus-community/kube-prometheus-stack --namespace=monitoring
NAME: stable
LAST DEPLOYED: Sun Sep  1 17:01:16 2024
NAMESPACE: monitoring
STATUS: deployed
REVISION: 1
NOTES:
kube-prometheus-stack has been installed. Check its status by running:
  kubectl --namespace monitoring get pods -l "release=stable"

Visit https://github.com/prometheus-operator/kube-prometheus for instructions on how to create & configure Alertmanager and Prometheus instances using the Operator.
```
5. Проверил работу Pods и svc  в namespace monitoring:

```shell
ubuntu@node0:~$ kubectl --namespace monitoring get pods
NAME                                                     READY   STATUS    RESTARTS   AGE
alertmanager-stable-kube-prometheus-sta-alertmanager-0   2/2     Running   0          38m
prometheus-stable-kube-prometheus-sta-prometheus-0       2/2     Running   0          38m
stable-grafana-5448785bb6-dgznw                          3/3     Running   0          38m
stable-kube-prometheus-sta-operator-744c468ccd-qmqcz     1/1     Running   0          38m
stable-kube-state-metrics-784c9bff7d-d2fw4               1/1     Running   0          38m
stable-prometheus-node-exporter-bw82g                    1/1     Running   0          38m
stable-prometheus-node-exporter-gvphf                    1/1     Running   0          38m
stable-prometheus-node-exporter-j9dq4                    1/1     Running   0          38m

ubuntu@node0:~$ kubectl get svc
NAME                                      TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
alertmanager-operated                     ClusterIP   None            <none>        9093/TCP,9094/TCP,9094/UDP   42m
prometheus-operated                       ClusterIP   None            <none>        9090/TCP                     42m
stable-grafana                            ClusterIP   10.233.35.129   <none>        80/TCP                       42m
stable-kube-prometheus-sta-alertmanager   ClusterIP   10.233.36.128   <none>        9093/TCP,8080/TCP            42m
stable-kube-prometheus-sta-operator       ClusterIP   10.233.7.191    <none>        443/TCP                      42m
stable-kube-prometheus-sta-prometheus     ClusterIP   10.233.16.210   <none>        9090/TCP,8080/TCP            42m
stable-kube-state-metrics                 ClusterIP   10.233.4.73     <none>        8080/TCP                     42m
stable-prometheus-node-exporter           ClusterIP   10.233.2.45     <none>        9100/TCP                     42m

```
6. Для доступа к Grafana из вне кластера, отредактировал текущий конфигурационный файл svc:

```
metadata:
  labels:
    app.kubernetes.io/name: grafana
  name: grafana-nodeport
  namespace: monitoring
spec:
  type: NodePort
  ports:
    - protocol: TCP
      port: 3000
      targetPort: 3000
      nodePort: 32000
```
7. Доступ по http к web интерфейсу Grafana:

![Grafana](IMG/Grafana.PNG)

8. Для входа необходимо получить пароль:

```
ubuntu@node0:~$ kubectl get secret --namespace monitoring stable-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
prom-operator
```

9. Теперь доступен мониторинг кластера Kubernetes:

![Monitoring](IMG/Monitoring.PNG)

10. Для установки ранее подготовленного приложения, воспользуюсь подготовленым для этого helm chart [my-app](https://github.com/Midzaru2011/myapp/tree/main/k8s/MyChart1):

```shell
ubuntu@node0:~$ kubectl create namespace myapp 
namespace/myapp created

ubuntu@node0:~$ helm repo add sasha https://midzaru2011.github.io/myapp/
"sasha" has been added to your repositories

ubuntu@node0:~$ helm install myapp1 sasha1/my-app --namespace myapp 
NAME: myapp1
LAST DEPLOYED: Sun Sep  1 18:05:18 2024
NAMESPACE: myapp
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
---------------------------------------------------------

Content of NOTES.txt appears after deploy.
Deployed version 0.1.0.

---------------------------------------------------------

ubuntu@node0:~$ helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "sasha1" chart repository
...Successfully got an update from the "prometheus-community" chart repository
Update Complete. ⎈Happy Helming!⎈

```
11. Теперь приложение доступно по порту, указанному в файле переменных [values.yaml](https://github.com/Midzaru2011/myapp/blob/main/k8s/MyChart1/values.yaml) на каждой рабочей ноде кластера:

![Node-1](IMG/Deployment.PNG)
![Node-2](IMG/Deployment1.PNG)

## Установка и настройка CI/CD

<details><summary>Задание №5</summary>

Осталось настроить ci/cd систему для автоматической сборки docker image и деплоя приложения при изменении кода.

Цель:

1. Автоматическая сборка docker образа при коммите в репозиторий с тестовым приложением.
2. Автоматический деплой нового docker образа.

Можно использовать [teamcity](https://www.jetbrains.com/ru-ru/teamcity/), [jenkins](https://www.jenkins.io/), [GitLab CI](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/) или GitHub Actions.

Ожидаемый результат:

1. Интерфейс ci/cd сервиса доступен по http.
2. При любом коммите в репозиторие с тестовым приложением происходит сборка и отправка в регистр Docker образа.
3. При создании тега (например, v1.0.0) происходит сборка и отправка с соответствующим label в регистри, а также деплой соответствующего Docker образа в кластер Kubernetes.

</details>

---

## Решение

Для выполнения этого задания использую развернутый через Terraform сервер Jenkins (CI), а для настройки CD установленный в кластер Kubernetes ArgoCD.

1. Для автоматической сборки Docker Image моего приложения по коммиту в ремозиторий с файлами приложения, необходимо настроить webhook. Для этого, необходимо в настройках репозитория прописать адрес, по которому будет работь Jenkins сервер:

![Webhook](IMG/Webhook.PNG)
![Webhook](IMG/Webhook2.PNG)
![alt text](IMG/Webhook3.PNG)

2. В jenkins необходимо настроить подключение к репозиторию GitHub, в котором будет располагаться код приложения, для этого нужно создать Global Credantional для GitHub:

![GitHub](IMG/GitHub.PNG)

3. Для того, чтобы jenkins мог отправлять собранный Docker Image в DockerHub, также необходимо создать Global Credantional для DockerHub, используя сгенерируемый в DockerHub токен:

![Docker](<IMG/DockerHub token.PNG>)
![alt text](IMG/DockerHub1.PNG)

4. Для настроки CI pipeline используется [Jenkinsfile](https://github.com/Midzaru2011/myapp/blob/main/Jenkinsfile), который расположен в репозитории с кодом приложения. Создал джоб, который использует этот файл для автоматической сборки и отправки собранного образа в DockerHub по коммиту в репозиторий и указанному тэгу:



## Что необходимо для сдачи задания?

1. Репозиторий с конфигурационными файлами Terraform и готовность продемонстрировать создание всех ресурсов с нуля.
2. Пример pull request с комментариями созданными atlantis'ом или снимки экрана из Terraform Cloud или вашего CI-CD-terraform pipeline.
3. Репозиторий с конфигурацией ansible, если был выбран способ создания Kubernetes кластера при помощи ansible.
4. Репозиторий с Dockerfile тестового приложения и ссылка на собранный docker image.
5. Репозиторий с конфигурацией Kubernetes кластера.
6. Ссылка на тестовое приложение и веб интерфейс Grafana с данными доступа.
7. Все репозитории рекомендуется хранить на одном ресурсе (github, gitlab)
