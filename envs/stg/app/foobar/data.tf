data "aws_caller_identity" "self" {}
data "aws_region" "current" {}

data "terraform_remote_state" "network_main" {
   
  backend = "s3"
  config = {
    bucket = "tfstate保存用のs3バケット名"                                #なければ事前に作成
    key    = "${local.system_name}/${local.env_name}/netowrk/main_v1.0.0.tfstate" #保存先パス
    region = "ap-northeast-1"
  }
}

data "terraform_remote_state" "routing_domain_name" {
  backend = "s3"

  config = {
    bucket = "tfstate保存用のs3バケット名"                                #なければ事前に作成
    key    = "${local.system_name}/${local.env_name}/rooting/domain_name_v1.0.0.tfstate" #保存先パス
    region = "ap-northeast-1"
  }
}