terraform {
  backend "s3" {
    bucket = "projectsa"                                #なければ事前に作成
    key    = "projectA/prod/app/foobar_v1.0.0.tfstate" #保存先パス
    region = "ap-northeast-1"
  }
}