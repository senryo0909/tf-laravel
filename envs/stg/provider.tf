provider "aws" {
    region = "ap-northeast-1"

    default_tags { # 3.38以降は共通タグが付けられるようになった
      tags = {
        Env = "stg"
        System = "projectA"
      }
    }
}

terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "3.42.0"
    }
  }

  required_version = "1.3.9"
}