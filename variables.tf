/* 変数定義 */


// OCI 全般・API Key 設定
// ====================================================================================================

variable "region" {
  description = "リージョン (ex. us-ashburn-1)"
}

variable "tenancy_ocid" {
  description = "テナンシの OCID"
}

variable "user_ocid" {
  description = "Terraform を実行するユーザの OCID (Resource Manager 実行時は不要)"
}

variable "fingerprint" {
  description = "Terraform を実行するユーザの API Key のフィンガープリント (Resource Manager 実行時は不要)"
}

variable "private_key_path" {
  description = "Terraform を実行するユーザの API Key 秘密鍵のフルパス (Resource Manager 実行時は不要)"
}

variable "compartment_ocid" {
  description = "コンパートメントの OCID"
}


// OKE 全体
// ====================================================================================================

variable "oke_cluster_name_prefix" {
  description = "OKE クラスタを構成するリソース名称の接頭辞"
}

variable "oke_kubernetes_version" {
  description = "使用する Kubernetes のバージョン (ex. v1.12.7)"
  default     = "v1.12.7"
}


// OKE Node Pool
// ====================================================================================================

variable "oke_node_pool_node_shapes" {
  description = "Node Pool のシェイプ (複数指定した場合はその数だけ Node Pool が作成される)・List の数は oke_node_pool_quantities_per_subnet と合わせる"
  default     = [
    "VM.Standard1.1"
  ]
}

variable "oke_node_pool_kubernetes_version" {
  description = "Node Pool 内の Worker Node で使用する Kubernetes のバージョン"
  default     = "v1.12.7"
}

variable "oke_node_pool_image_name" {
  description = "Node Pool 内の Worker Node で使用するイメージ名"
  default     = "Oracle-Linux-7.6"
}

variable "oke_node_pool_quantities_per_subnet" {
  description = "1つの Subnet に配置する Node 数の指定・List の数は oke_node_pool_node_shapes と合わせる"
  default     = [
    1
  ]
}

variable "oke_node_pool_ssh_public_key" {
  description = "Worker Node への SSH 接続用の公開鍵"
}


// VCN
// ====================================================================================================

variable "vcn_dns_label" {
  description = "OKE クラスタを構成する VCN の DNS Label 名・ハイフンを許容しないので注意"
}

variable "subnet_dns_label_load_balancer_ad1" {
  description = "Load Balancer AD1 の Subnet の DNS ラベル名・ハイフンを許容しないので注意 (ex. loadbalancer1)"
  default     = "loadbalancer1"
}

variable "subnet_dns_label_load_balancer_ad2" {
  description = "Load Balancer AD2 の Subnet の DNS ラベル名・ハイフンを許容しないので注意 (ex. loadbalancer2)"
  default     = "loadbalancer2"
}

variable "subnet_dns_label_worker_node_ad1" {
  description = "Worker Node AD1 の Subnet の DNS ラベル名・ハイフンを許容しないので注意 (ex. workernode1)"
  default     = "workernode1"
}

variable "subnet_dns_label_worker_node_ad2" {
  description = "Worker Node AD2 の Subnet の DNS ラベル名・ハイフンを許容しないので注意 (ex. workernode2)"
  default     = "workernode2"
}

variable "subnet_dns_label_worker_node_ad3" {
  description = "Worker Node AD3 の Subnet の DNS ラベル名・ハイフンを許容しないので注意 (ex. workernode3)"
  default     = "workernode3"
}

variable "subnet_dns_label_bastion" {
  description = "踏み台サーバの Subnet の DNS ラベル名・ハイフンを許容しないので注意 (ex. bastion)"
  default     = "bastion"
}


// Instance
// ====================================================================================================

variable "instance_image_ocids" {
  description = "Instanc イメージの OCID マップ"
  type        = "map"
  default     = {
    // - イメージ定義のベスト・プラクティス : https://www.terraform.io/docs/providers/oci/guides/best_practices.html#referencing-images
    // - イメージ情報は次の URL より確認できる : https://docs.us-phoenix-1.oraclecloud.com/images/
    // - 以下は Oracle-Linux-7.6-2019.05.14-0 イメージの OCID を指定している : https://docs.cloud.oracle.com/iaas/images/image/54f22559-7638-4da9-9e09-7fc78527608c/
    ap-seoul-1     = "ocid1.image.oc1.ap-seoul-1.aaaaaaaalhbuvdg453ddyhvnbk4jsrw546zslcfyl7vl4oxfgplss3ovlm4q"
    ap-tokyo-1     = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaamc2244t7h3gwrrci5z4ni2jsulwcg76gugupkb6epzrypawcz4hq"
    ca-toronto-1   = "ocid1.image.oc1.ca-toronto-1.aaaaaaaakjkxzw33dcocgu2oylpllue34tjtyngwru7pcpqn4qh2nwon7n7a"
    eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaandqh4s7a3oe3on6osdbwysgddwqwyghbx4t4ryvtcwk5xikkpvhq"
    uk-london-1    = "ocid1.image.oc1.uk-london-1.aaaaaaaa2xe7cufdwkksdazshtmqaddgd72kdhiyoqurtoukjklktf4nxkbq"
    us-ashburn-1   = "ocid1.image.oc1.iad.aaaaaaaa4bfsnhv2cd766tiw5oraw2as7g27upxzvu7ynqwipnqfcfwqskla"
    us-phoenix-1   = "ocid1.image.oc1.phx.aaaaaaaavtjpvg4njutkeu7rf7c5lay6wdbjhd4cxis774h7isqd6gktqzoa"
  }
}

variable "instance_shape" {
  description = "Instance のシェイプ"
  default     = "VM.Standard1.1"
}

variable "instance_ssh_public_key" {
  description = "Instance への SSH 接続用の公開鍵"
}

variable "instance_hostname_label_bastion_ad1" {
  description = "踏み台サーバ AD1 のホスト名 (ex. bastion1)"
  default     = "bastion1"
}
