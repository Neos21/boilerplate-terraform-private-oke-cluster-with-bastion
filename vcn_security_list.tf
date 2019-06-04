/* 
 * OKE で使用する VCN 内の Subnet に適用する Security Lists
 * 
 * - https://www.terraform.io/docs/providers/oci/r/core_security_list.html
 */

/* Load Balancer : Inbound … インターネット (HTTP 80・HTTPS 443) からの通信 */
resource "oci_core_security_list" "load_balancer_from_internet" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_vcn.oke_vcn.id}"
  display_name   = "load-balancer-from-internet"
  ingress_security_rules = [
    {
      stateless = false
      source    = "${local.cidr_public_internet}"
      protocol  = "${local.security_list_protocol_tcp}"
      tcp_options { min = "80" max = "80" }
    },
    {
      stateless = false
      source    = "${local.cidr_public_internet}"
      protocol  = "${local.security_list_protocol_tcp}"
      tcp_options { min = "443" max = "443" }
    }
  ]
}

/* Load Balancer : Outbound … 同一 VCN 内を含めた全インターネットへの通信 */
resource "oci_core_security_list" "load_balancer_to_externals" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_vcn.oke_vcn.id}"
  display_name   = "load-balancer-to-externals"
  egress_security_rules = [
    {
      stateless   = false
      destination = "${local.cidr_public_internet}"
      protocol    = "${local.security_list_protocol_all}"
    }
  ]
}

/* Worker Node : Inbound … 同一 VCN 内からの通信 */
resource "oci_core_security_list" "worker_node_from_vcn" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_vcn.oke_vcn.id}"
  display_name   = "worker-node-from-vcn"
  ingress_security_rules = [
    // 同一 VCN 内 : Load Balancer から・Worker Node 同士 (Kubernetes Pod など)・踏み台サーバからの通信も含む
    {
      stateless = false
      source    = "${local.cidr_cluster_wide}"
      protocol  = "${local.security_list_protocol_all}"
    }
  ]
}

/*
 * Worker Node : Inbound … OKE からのヘルスチェック用の通信
 * 
 * - https://docs.cloud.oracle.com/iaas/Content/ContEng/Concepts/contengnetworkconfig.htm#securitylistconfig
 *   - SSH 22 ポートを許可すべき CIDR ブロック情報
 */
resource "oci_core_security_list" "worker_node_from_master_for_health_check" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_vcn.oke_vcn.id}"
  display_name   = "worker-node-from-master-for-health-check"
  ingress_security_rules = [
    {  source = "130.35.0.0/16"   stateless = false  protocol = "${local.security_list_protocol_tcp}"  tcp_options { min = "22" max = "22" }  },
    {  source = "134.70.0.0/17"   stateless = false  protocol = "${local.security_list_protocol_tcp}"  tcp_options { min = "22" max = "22" }  },
    {  source = "138.1.0.0/16"    stateless = false  protocol = "${local.security_list_protocol_tcp}"  tcp_options { min = "22" max = "22" }  },
    {  source = "140.91.0.0/17"   stateless = false  protocol = "${local.security_list_protocol_tcp}"  tcp_options { min = "22" max = "22" }  },
    {  source = "147.154.0.0/16"  stateless = false  protocol = "${local.security_list_protocol_tcp}"  tcp_options { min = "22" max = "22" }  },
    {  source = "192.29.0.0/16"   stateless = false  protocol = "${local.security_list_protocol_tcp}"  tcp_options { min = "22" max = "22" }  }
  ]
}

/* Worker Node : Outbound … 同一 VCN 内を含めた全インターネットへの通信 */
resource "oci_core_security_list" "worker_node_to_externals" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_vcn.oke_vcn.id}"
  display_name   = "worker-node-to-externals"
  egress_security_rules = [
    {
      stateless   = false
      destination = "${local.cidr_public_internet}"
      protocol    = "${local.security_list_protocol_all}"
    }
  ]
}

/* 踏み台サーバ : Inbound … インターネットからの SSH 22 通信 */
resource "oci_core_security_list" "bastion_from_ssh" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_vcn.oke_vcn.id}"
  display_name   = "bastion-from-ssh"
  ingress_security_rules = [
    {
      stateless = false
      source    = "${local.cidr_public_internet}"
      protocol  = "${local.security_list_protocol_tcp}"
      tcp_options { min = "22" max = "22" }
    }
  ]
}

/* 踏み台サーバ : Outbound … 同一 VCN 内を含めた全インターネットへの通信 */
resource "oci_core_security_list" "bastion_to_externals" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_vcn.oke_vcn.id}"
  display_name   = "bastion-to-externals"
  egress_security_rules = [
    {
      stateless   = false
      destination = "${local.cidr_public_internet}"
      protocol    = "${local.security_list_protocol_all}"
    }
  ]
}
