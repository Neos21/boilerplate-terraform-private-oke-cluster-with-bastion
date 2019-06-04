/* 
 * OCI プロバイダ定義
 * 
 * - https://www.terraform.io/docs/providers/oci/index.html
 */
provider "oci" {
  region           = "${var.region}"
  // 以下は API Key 認証での実行時のみ必要
  tenancy_ocid     = "${var.tenancy_ocid}"
  user_ocid        = "${var.user_ocid}"
  fingerprint      = "${var.fingerprint}"
  private_key_path = "${var.private_key_path}"
}

/* CIDR ブロックの定義 */
locals {
  cidr_public_internet       = "0.0.0.0/0"     // インターネットとの通信
  cidr_cluster_wide          = "10.0.0.0/16"   // VCN 内
  cidr_vcn_load_balancer_ad1 = "10.0.20.0/24"  // Load Balancer AD1
  cidr_vcn_load_balancer_ad2 = "10.0.21.0/24"  // Load Balancer AD2
  cidr_vcn_worker_node_ad1   = "10.0.10.0/24"  // OKE Worker Node AD1
  cidr_vcn_worker_node_ad2   = "10.0.11.0/24"  // OKE Worker Node AD2
  cidr_vcn_worker_node_ad3   = "10.0.12.0/24"  // OKE Worker Node AD3
  cidr_vcn_bastion           = "10.0.30.0/24"  // 踏み台サーバ
}

/*
 * Security List の設定に使用するプロトコル番号の定義
 * 
 * - https://www.terraform.io/docs/providers/oci/r/core_security_list.html
 * - http://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml
 */
locals {
  security_list_protocol_icmp = "1"   // ICMP
  security_list_protocol_tcp  = "6"   // TCP
  security_list_protocol_udp  = "17"  // UDP
  security_list_protocol_all  = "all"
}

/* 
 * 当該テナンシで利用可能な AD の一覧を取得する
 * 
 * - https://www.terraform.io/docs/providers/oci/d/identity_availability_domains.html
 * - oci_identity_availability_domain Data Source からは ad_number が取得できるがコレには ad_number がない
 *   - https://www.terraform.io/docs/providers/oci/d/identity_availability_domain.html
 */
data "oci_identity_availability_domains" "availability_domains" {
  compartment_id = "${var.tenancy_ocid}"
}
