import boto3
import sys
import json
from botocore.exceptions import ClientError
from typing import Dict, Optional
from botocore.config import Config


def generate_presigned_urls(
    bucket_name: str, object_key: str = "index.html", expiration: int = 3600
) -> Optional[Dict[str, str]]:
    try:
        s3_client = boto3.client(
            "s3",
            region_name="ap-northeast-1",
            config=Config(s3={"addressing_style": "virtual"}),
        )

        # アップロード用URL生成
        upload_url = s3_client.generate_presigned_url(
            ClientMethod="put_object",
            Params={"Bucket": bucket_name, "Key": object_key},
            ExpiresIn=expiration,
        )

        # ダウンロード用URL生成
        download_url = s3_client.generate_presigned_url(
            ClientMethod="get_object",
            Params={"Bucket": bucket_name, "Key": object_key},
            ExpiresIn=expiration,
        )

        return {"upload_url": upload_url, "download_url": download_url}

    except ClientError as e:
        print(f"エラーが発生しました: {str(e)}", file=sys.stderr)
        return None
    except Exception as e:
        print(f"予期せぬエラーが発生しました: {str(e)}", file=sys.stderr)
        return None


def main():
    bucket_name = sys.argv[1]
    result = generate_presigned_urls(bucket_name)

    if result:
        print(json.dumps(result, indent=2, ensure_ascii=False))
        sys.exit(0)
    else:
        sys.exit(1)


if __name__ == "__main__":
    main()
