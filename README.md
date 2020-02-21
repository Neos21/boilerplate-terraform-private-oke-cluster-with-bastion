# Terraform Private OKE Cluster With Bastion

Terraform OCI Provider を使用して OKE クラスタと踏み台サーバを立てるボイラープレート。

- OCI : Oracle Cloud Infrastructure
- OKE : Oracle Container Engine for Kubernetes


## 主な仕様

- 3つの AD が存在する前提で OKE クラスタを構築する
    - 2019年5月現在、東京リージョン (`ap-tokyo-1`) には AD が1つしか存在しないため、このボイラープレートは適用できない
- Node Pool に割り当てる Subnet は Public IP を持たない Private Subnet とする
- 踏み台サーバは AD1 に1台立て、予約済 Public IP を割り当てる


## ローカルでの実行方法

- `terraform.tfvars.example` を参考に、変数値をまとめた `terraform.tfvars` ファイルを用意する
- `$ terraform init` を実行し、`local` プラグインと `oci` プラグインを準備する
- `$ terraform plan -var-file='./terraform.tfvars'` を実行し、実行計画を確認する
- `$ terraform apply -var-file='./terraform.tfvars'` を実行し、環境を構築する
- 環境を破棄する場合は、`$ terraform destroy -var-file='./terraform.tfvars'` を実行する


## OCI Resource Manager での実行方法

OCI Resource Manager で実行する際は、OCI Provider にユーザ情報を設定する必要がないため、いくつかの変数宣言を削除する。これにより KubeConfig ファイルも生成できなくなるため、KubeConfig を生成する宣言も削除する。

- `main.tf`
    - `provider "oci"` ブロックから `region` 以外の指定をコメントアウトする
- `oke.tf`
    - `data "oci_containerengine_cluster_kube_config" "oke_kube_config"`・`resource "local_file" "kubeconfig"` ブロックをコメントアウトする
- `variables.tf`
    - `variable "user_ocid"`・`variable "fingerprint"`・`variable "private_key_path"` の3つの宣言をコメントアウトする

※ OCI Resource Manager で OCI Provider にユーザ情報を指定していると、`provider.oci: user credentials user_ocid, fingerprint, private_key_path should be removed from the configuration` というエラーが発生してしまう。


## Author

[Neo](http://neo.s21.xrea.com/)


## Links

- [Neo's World](http://neo.s21.xrea.com/)
- [Corredor](https://neos21.hatenablog.com/)
- [Murga](https://neos21.hatenablog.jp/)
- [El Mylar](https://neos21.hateblo.jp/)
- [Neo's GitHub Pages](https://neos21.github.io/)
- [GitHub - Neos21](https://github.com/Neos21/)
