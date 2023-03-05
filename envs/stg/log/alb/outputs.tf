# alb作成にはs3のアカウントIDが必要となるため
# terraform_remote_stateを使って下記の値を他のファイルで参照可能
output "s3_bucket_this_id" {
    value = aws_s3_bucket.this.id
}