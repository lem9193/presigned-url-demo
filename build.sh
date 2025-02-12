#!/bin/bash

set -eu

set -o pipefail

# 使用方法を表示する関数
show_usage() {
  cat <<'EOF'
使用方法: $0 <action> [resource] [add_route]

アクション:
    init      - リソースを初期化します
    apply     - リソースをデプロイします
    destroy   - リソースを削除します
    get-url   - 署名付きURLを取得します

リソース (apply/destroyの場合必須):
    consumer  - コンシューマーリソース
    provider  - プロバイダーリソース

オプション:
    add_route - providerリソースの初回デプロイの場合は "false" を指定。2回目以降は "true" を指定。
EOF
}

# S3バケット名を取得する関数
get_s3_bucket_name() {
  local bucket_name
  if ! bucket_name=$(aws s3 ls | grep -o 'presigned-url-demo-provider-bucket-[^ ]*' || true); then
    echo "エラー: S3バケットの取得に失敗しました" >&2
    return 1
  fi
  if [ -z "${bucket_name}" ]; then
    echo "エラー: 対象のS3バケットが見つかりません" >&2
    return 1
  fi
  echo "${bucket_name}"
}

# メイン処理
main() {
  # 引数の検証
  local action="${1:-}"
  local resource="${2:-}"
  local add_route="${3:-false}"

  # アクションが指定されていない場合
  if [ -z "${action}" ]; then
    echo "エラー: アクションを指定してください" >&2
    show_usage
    return 1
  fi

  # アクションの検証
  case "${action}" in
  "init")
    echo "リソースを初期化します..."
    if ! cd provider; then
      echo "エラー: providerディレクトリへの移動に失敗しました" >&2
      return 1
    fi
    if ! terraform init; then
      echo "エラー: Terraformコマンドの実行に失敗しました" >&2
      return 1
    fi
    cd - || return 1
    if ! cd consumer; then
      echo "エラー: consumerディレクトリへの移動に失敗しました" >&2
      return 1
    fi
    if ! terraform init; then
      echo "エラー: Terraformコマンドの実行に失敗しました" >&2
      return 1
    fi
    cd - || return 1
    ;;
  "apply" | "destroy")
    # リソースタイプの検証
    if [ -z "${resource}" ]; then
      echo "エラー: リソースタイプを指定してください" >&2
      show_usage
      return 1
    fi
    if [ "${resource}" != "consumer" ] && [ "${resource}" != "provider" ]; then
      echo "エラー: 無効なリソースタイプです: ${resource}" >&2
      show_usage
      return 1
    fi

    # providerリソースの削除時にS3バケットの中身を空にする
    if [ "${action}" = "destroy" ] && [ "${resource}" = "provider" ]; then
      echo "S3バケットの内容を削除します..."
      local bucket_name
      bucket_name=$(get_s3_bucket_name) || return 1
      aws s3 rm "s3://${bucket_name}/index.html" || true
    fi

    echo "${resource} の ${action} を開始します..."
    if ! cd "${resource}"; then
      echo "エラー: ${resource}ディレクトリへの移動に失敗しました" >&2
      return 1
    fi

    # Terraformコマンドの実行
    if [ "${resource}" = "provider" ]; then
      if ! terraform "${action}" --auto-approve -var="add_route=${add_route}"; then
        echo "エラー: Terraformコマンドの実行に失敗しました" >&2
        return 1
      fi
    else
      if ! terraform "${action}" --auto-approve; then
        echo "エラー: Terraformコマンドの実行に失敗しました" >&2
        return 1
      fi
    fi
    cd - || return 1
    ;;

  "get-url")
    echo "署名付きURLを取得します..."
    local bucket_name
    bucket_name=$(get_s3_bucket_name) || return 1
    if ! python get_presigned_url.py "${bucket_name}"; then
      echo "エラー: 署名付きURLの取得に失敗しました" >&2
      return 1
    fi
    ;;

  *)
    echo "エラー: 無効なアクションです: ${action}" >&2
    show_usage
    return 1
    ;;
  esac

  echo "処理が正常に完了しました"
  return 0
}

# スクリプトの実行
main "$@"
