/* OKE クラスタ関連 */

/* 
 * OKE クラスタを作成する
 * 
 * - https://www.terraform.io/docs/providers/oci/r/containerengine_cluster.html
 */
resource "oci_containerengine_cluster" "oke_cluster" {
  compartment_id     = "${var.compartment_ocid}"
  name               = "${var.oke_cluster_name_prefix}-cluster"
  kubernetes_version = "${var.oke_kubernetes_version}"
  vcn_id             = "${oci_core_vcn.oke_vcn.id}"
  options {
    // Load Balancer 用の Subnet を紐付ける
    service_lb_subnet_ids = [
      "${oci_core_subnet.load_balancer_ad1.id}",
      "${oci_core_subnet.load_balancer_ad2.id}"
    ]
    add_ons {
      is_kubernetes_dashboard_enabled = true  // 固定値
      is_tiller_enabled               = true  // 固定値
    }
  }
}

/* 
 * Node Pool をシェイプ別に作成する
 * 
 * - https://www.terraform.io/docs/providers/oci/r/containerengine_node_pool.html
 */
resource "oci_containerengine_node_pool" "oke_node_pool" {
  count               = "${length(var.oke_node_pool_node_shapes)}"
  cluster_id          = "${oci_containerengine_cluster.oke_cluster.id}"
  compartment_id      = "${var.compartment_ocid}"
  name                = "node-pool-${count.index}"  // Node Pool 名
  kubernetes_version  = "${var.oke_node_pool_kubernetes_version}"
  node_image_name     = "${var.oke_node_pool_image_name}"
  node_shape          = "${element(var.oke_node_pool_node_shapes, count.index)}"
  quantity_per_subnet = "${element(var.oke_node_pool_quantities_per_subnet, count.index)}"
  ssh_public_key      = "${var.oke_node_pool_ssh_public_key}"
  subnet_ids = [
    "${oci_core_subnet.worker_node_ad1.id}",
    "${oci_core_subnet.worker_node_ad2.id}",
    "${oci_core_subnet.worker_node_ad3.id}"
  ]
}

/* 
 * OCI Provider に設定した OCI ユーザで Kube Config YAML ファイルを生成する
 * 
 * - Resource Manager 使用時は正しく出力できないので無効化すること
 * - https://www.terraform.io/docs/providers/oci/d/containerengine_cluster_kube_config.html
 */
data "oci_containerengine_cluster_kube_config" "oke_kube_config" {
  cluster_id    = "${oci_containerengine_cluster.oke_cluster.id}"
  expiration    = 2592000000000000  // 固定値
  token_version = "1.0.0"           // 固定値
}

/* 
 * 取得した Kube Config YAML ファイルの内容をファイルに書き出す
 * 
 * - Resource Manager 使用時は正しく出力できないので無効化すること
 */
resource "local_file" "kubeconfig" {
  content  = "${data.oci_containerengine_cluster_kube_config.oke_kube_config.content}"
  filename = "${path.module}/generated/kubeconfig"
}
