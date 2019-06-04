/*
 * OKE で使用する VCN 関連
 * 
 * - 構成例
 *   - https://docs.cloud.oracle.com/iaas/Content/ContEng/Concepts/contengnetworkconfigexample.htm#example-private-cluster-config
 *   - https://docs.oracle.com/cd/E97706_01/Content/ContEng/Concepts/contengnetworkconfigexample.htm#example-private-cluster-config
 */

/* 
 * VCN を作成する
 * 
 * - https://www.terraform.io/docs/providers/oci/r/core_vcn.html
 *   - 以前は「oci_core_virtual_network」という名称だった
 * - https://www.terraform.io/docs/providers/oci/guides/managing_default_resources.html
 *   - VCN と同時作成する他のリソースについて
 */
resource "oci_core_vcn" "oke_vcn" {
  compartment_id = "${var.compartment_ocid}"
  cidr_block     = "${local.cidr_cluster_wide}"
  display_name   = "${var.oke_cluster_name_prefix}-vcn"
  dns_label      = "${var.vcn_dns_label}"  // ハイフンを許容しないので注意
}

/* 
 * Default Route Table
 * 
 * - https://www.terraform.io/docs/providers/oci/r/core_route_table.html
 * - https://www.terraform.io/docs/providers/oci/guides/managing_default_resources.html
 *   - VCN と同時作成するデフォルトを変更するための特別な Resource 名
 */
resource "oci_core_default_route_table" "default_route_table" {
  // manage_default_resource_id 指定によって Default Route Table を特定し変更する
  manage_default_resource_id = "${oci_core_vcn.oke_vcn.default_route_table_id}"
  display_name               = "default-route-table"
  route_rules {
    network_entity_id = "${oci_core_internet_gateway.internet_gateway.id}"  // Internet Gateway
    destination       = "${local.cidr_public_internet}"
  }
}

/* 
 * NAT Gateway 用の Route Table : Worker Node が配置される Private Subnet に適用する
 * 
 * - https://www.terraform.io/docs/providers/oci/r/core_route_table.html
 */
resource "oci_core_route_table" "nat_route_table" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_vcn.oke_vcn.id}"
  display_name   = "nat-route-table"
  route_rules {
    network_entity_id = "${oci_core_nat_gateway.nat_gateway.id}"
    destination       = "${local.cidr_public_internet}"
  }
}

/* 
 * Internet Gateway
 * 
 * - https://www.terraform.io/docs/providers/oci/r/core_internet_gateway.html
 */
resource "oci_core_internet_gateway" "internet_gateway" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_vcn.oke_vcn.id}"
  display_name   = "internet-gateway"
}

/* 
 * NAT Gateway : Private Subnet に Worker Node を配置する際は必要
 * 
 * - https://www.terraform.io/docs/providers/oci/r/core_nat_gateway.html
 */
resource "oci_core_nat_gateway" "nat_gateway" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_vcn.oke_vcn.id}"
  display_name   = "nat-gateway"
}
