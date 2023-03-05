# 他のtfstateを参照できるようにする(output宣言されていないものは不可能)
data "terraform_remote_state" "network_main"{
    backend = "s3"
    config = {
        bucket = "tfstate保存用のS3バケット名"
        key = "${local.system_name}/${local.env_name}/network/main_v1.0.0.tfstate"
        region = "apnortheast1"
    }
}

data "terraform_remote_state" "log_alb" {
        backend = "s3"
        config = {
            bucket = "tfstate保存用のS3バケット名"
            key = "${local.system_name}/${local.env_name}/log/alb_v1.0.0.tfstate"
            region = "apnortheast1"
    }
}
