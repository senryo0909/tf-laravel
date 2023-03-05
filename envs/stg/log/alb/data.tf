# elbのIDはAWSのIAMで使うアカウントと違い、AWSがリージョンごとに管理している
# 例)ap-northeast-1であれば、582318560864など
# 下記は引数regionをを持つが、providerで設定しているので記載不要
data "aws_elb_service_account" "current" {}