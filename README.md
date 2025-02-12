# S3 署名付き URL デモプロジェクト

## 概要

このプロジェクトは、閉域網環境で AWS S3 の署名付き URL（Presigned URL）を使用するためのデモンストレーションプロジェクトです。Terraform を使用してインフラストラクチャをコード化（IaC）し、プロバイダー側とコンシューマー側の 2 つの主要コンポーネントで構成されています。

## 前提条件

aws-cli: 2.24.0
Terraform: v1.8.4
Python: 3.12.4

## プロジェクト構成

```
.
├── provider/ # プロバイダー側のインフラ定義
│ ├── main.tf
│ ├── variables.tf
│ ├── provider.tf
│ ├── html/
│ └── module
├── consumer/ # コンシューマー側のインフラ定義
│ ├── main.tf
│ ├── variables.tf
│ ├── provider.tf
│ └── module
├── build.sh # ビルドスクリプト
└── get_presigned_url.py # S3 署名付き URL 生成スクリプト
```

## 構成リソース

- プロバイダーリソース

  - VPC 関連リソース
    - Interface 型 VPC エンドポイント
    - Gateway 型 VPC エンドポイント
  - S3 バケット
  - Route53 Resolver インバウンドエンドポイント

- コンシューマーリソース
  - VPC 関連リソース
    - EC2 インスタンスコネクトエンドポイント
  - EC2

## 環境構築

[build.sh](./build.sh)を使用して、各コマンドの実行を行います。
使用方法は[build.sh](./build.sh)を参照してください。

### スクリプトの権限付与

```bash
chmod +x build.sh
```
