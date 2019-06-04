/* Output : 結果出力用 */

/* 踏み台サーバ AD1 に割り当てた予約済 Public IP */
output "bastion_ad1_public_ip" {
  value = [ "${oci_core_public_ip.bastion_ad1_reserved_public_ip.ip_address}" ]
}
