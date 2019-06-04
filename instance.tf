/* 
 * Instance
 * 
 * - https://www.terraform.io/docs/providers/oci/r/core_instance.html
 * - https://github.com/terraform-providers/terraform-provider-oci/issues/680#issuecomment-452415263
 *   - インスタンスの作成後に予約済 Public IP を作成して割り当てる
 */

/* 踏み台サーバ AD1 */
resource "oci_core_instance" "bastion_ad1" {
  compartment_id      = "${var.compartment_ocid}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.availability_domains.availability_domains[0], "name")}"
  shape               = "${var.instance_shape}"
  display_name        = "bastion-ad1"
  source_details {
    source_type = "image"
    source_id   = "${var.instance_image_ocids[var.region]}"  // 当該リージョン用のイメージの OCID を指定する
  }
  create_vnic_details {
    subnet_id        = "${oci_core_subnet.bastion.id}"
    assign_public_ip = false  // 後で予約済 Public IP を割り当てるのでインスタンス作成時は Public IP を割り当てない
    hostname_label   = "${var.instance_hostname_label_bastion_ad1}"
  }
  metadata {
    ssh_authorized_keys = "${var.instance_ssh_public_key}"
  }
}

/* 踏み台サーバ AD1 の VNIC 一覧を取得する */
data "oci_core_vnic_attachments" "bastion_ad1_vnics" {
  compartment_id      = "${var.compartment_ocid}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.availability_domains.availability_domains[0], "name")}"
  instance_id         = "${oci_core_instance.bastion_ad1.id}"
}

/* 踏み台サーバ AD1 の VNIC 一覧からプライマリ VNIC を取得する */
data "oci_core_vnic" "bastion_ad1_primary_vnic" {
  vnic_id = "${lookup(data.oci_core_vnic_attachments.bastion_ad1_vnics.vnic_attachments[0], "vnic_id")}"
}

/* 踏み台サーバ AD1 のプライマリ VNIC に割り当てられている Private IP を取得する */
data "oci_core_private_ips" "bastion_ad1_private_ips" {
  vnic_id = "${data.oci_core_vnic.bastion_ad1_primary_vnic.id}"
}

/* 踏み台サーバ AD1 の Private IP を指定して予約済 Public IP を割り当てる */
resource "oci_core_public_ip" "bastion_ad1_reserved_public_ip" {
  compartment_id = "${var.compartment_ocid}"
  lifetime       = "RESERVED"  // 予約済 Public IP
  display_name   = "bastion-ad1-public-ip"
  private_ip_id  = "${lookup(data.oci_core_private_ips.bastion_ad1_private_ips.private_ips[0], "id")}"
}
