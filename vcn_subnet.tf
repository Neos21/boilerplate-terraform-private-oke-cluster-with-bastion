/*
 * OKE で使用する VCN 内の Subnets
 * 
 * - https://www.terraform.io/docs/providers/oci/r/core_subnet.html
 */

/* Load Balancer AD1 */
resource "oci_core_subnet" "load_balancer_ad1" {
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_vcn.oke_vcn.id}"
  display_name        = "load-balancer-ad1"
  availability_domain = "${lookup(data.oci_identity_availability_domains.availability_domains.availability_domains[0], "name")}"  // AD 名を指定することで AD 固有サブネットにする
  dns_label           = "${var.subnet_dns_label_load_balancer_ad1}"  // ハイフンを許容しない
  cidr_block          = "${local.cidr_vcn_load_balancer_ad1}"
  security_list_ids   = [
    "${oci_core_security_list.load_balancer_from_internet.id}",
    "${oci_core_security_list.load_balancer_to_externals.id}"
  ]
}

/* Load Balancer AD2 */
resource "oci_core_subnet" "load_balancer_ad2" {
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_vcn.oke_vcn.id}"
  display_name        = "load-balancer-ad2"
  availability_domain = "${lookup(data.oci_identity_availability_domains.availability_domains.availability_domains[1], "name")}"  // AD 名を指定することで AD 固有サブネットにする
  dns_label           = "${var.subnet_dns_label_load_balancer_ad2}"  // ハイフンを許容しない
  cidr_block          = "${local.cidr_vcn_load_balancer_ad2}"
  security_list_ids   = [
    "${oci_core_security_list.load_balancer_from_internet.id}",
    "${oci_core_security_list.load_balancer_to_externals.id}"
  ]
}

/* Worker Node AD1 */
resource "oci_core_subnet" "worker_node_ad1" {
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_vcn.oke_vcn.id}"
  display_name        = "worker-node-ad1"
  availability_domain = "${lookup(data.oci_identity_availability_domains.availability_domains.availability_domains[0], "name")}"  // OKE クラスタはリージョナル・サブネットを使えないので AD 固有サブネットにする
  dns_label           = "${var.subnet_dns_label_worker_node_ad1}"  // ハイフンを許容しない
  cidr_block          = "${local.cidr_vcn_worker_node_ad1}"
  route_table_id      = "${oci_core_route_table.nat_route_table.id}"  // NAT Gateway を通す
  security_list_ids   = [
    "${oci_core_security_list.worker_node_from_vcn.id}",
    "${oci_core_security_list.worker_node_from_master_for_health_check.id}",
    "${oci_core_security_list.worker_node_to_externals.id}"
  ]
  prohibit_public_ip_on_vnic = true  // true にすると Private Subnet になる
}

/* Worker Node AD2 */
resource "oci_core_subnet" "worker_node_ad2" {
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_vcn.oke_vcn.id}"
  display_name        = "worker-node-ad2"
  availability_domain = "${lookup(data.oci_identity_availability_domains.availability_domains.availability_domains[1], "name")}"  // OKE クラスタはリージョナル・サブネットを使えないので AD 固有サブネットにする
  dns_label           = "${var.subnet_dns_label_worker_node_ad2}"  // ハイフンを許容しない
  cidr_block          = "${local.cidr_vcn_worker_node_ad2}"
  route_table_id      = "${oci_core_route_table.nat_route_table.id}"  // NAT Gateway を通す
  security_list_ids   = [
    "${oci_core_security_list.worker_node_from_vcn.id}",
    "${oci_core_security_list.worker_node_from_master_for_health_check.id}",
    "${oci_core_security_list.worker_node_to_externals.id}"
  ]
  prohibit_public_ip_on_vnic = true  // true にすると Private Subnet になる
}

/* Worker Node AD3 */
resource "oci_core_subnet" "worker_node_ad3" {
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_vcn.oke_vcn.id}"
  display_name        = "worker-node-ad3"
  availability_domain = "${lookup(data.oci_identity_availability_domains.availability_domains.availability_domains[2], "name")}"  // OKE クラスタはリージョナル・サブネットを使えないので AD 固有サブネットにする
  dns_label           = "${var.subnet_dns_label_worker_node_ad3}"  // ハイフンを許容しない
  cidr_block          = "${local.cidr_vcn_worker_node_ad3}"
  route_table_id      = "${oci_core_route_table.nat_route_table.id}"  // NAT Gateway を通す
  security_list_ids   = [
    "${oci_core_security_list.worker_node_from_vcn.id}",
    "${oci_core_security_list.worker_node_from_master_for_health_check.id}",
    "${oci_core_security_list.worker_node_to_externals.id}"
  ]
  prohibit_public_ip_on_vnic = true  // true にすると Private Subnet になる
}

/* 中継サーバ用 */
resource "oci_core_subnet" "bastion" {
  // availability_domain を指定せずリージョナル・サブネットにする
  compartment_id    = "${var.compartment_ocid}"
  vcn_id            = "${oci_core_vcn.oke_vcn.id}"
  display_name      = "bastion"
  dns_label         = "${var.subnet_dns_label_bastion}"  // ハイフンを許容しない
  cidr_block        = "${local.cidr_vcn_bastion}"
  security_list_ids = [
    "${oci_core_security_list.bastion_from_ssh.id}",
    "${oci_core_security_list.bastion_to_externals.id}"
  ]
}
