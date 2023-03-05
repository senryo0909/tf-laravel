# github用のユーザー作成
resource "aws_iam_user" "github" {
    name = "${local.name_prefix}-${local.service_name}-github"
    tags = {
        Name = "${local.name_prefix}-${local.service_name}-gihtub"
    }
}

# 付与予定のデプロイ関連ロール
resource "aws_iam_role" "deployer" {
    name = "${local.name_prefix}-${local.service_name}-deployer"

    # 信頼ポリシー
    assume_role_policy = jsonencode(
        {
            "Version": "2012-10-17",
            "Statement":[
                {
                    "Effect":"Allow", # permission boundary
                    "Action":[ # identity policy
                        "sts:AssumeRole",
                        "sts:TagSession" # aws-actions/configure-aws-credentialsの機能内で、session tagが付与されることから、actionsのcredintialsで使うロールでは必須の権限
                    ],
                    "Principal": {
                        "AWS": aws_iam_user.github.arn #このロールを引き受けることができる信頼されたユーザー(信頼されたentity)
                    }
                }
            ]
        }
    )
    tags = {
      Name = "${local.name_prefix}-${local.service_name}-deployer"
    }
}

# ディレクトリで管理していない、aws管理された情報を呼び出すためにdataを利用
data "aws_iam_policy" "ecr_power_user" {
    arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser" # ecrの読み書きを行う権限
}

resource "aws_iam_role_policy_attachement" "role_deployer_policy_ecr_power_user" {
    role = aws_iam_role.deployer.name
    policy_arn = data.aws_iam_policy.ecr_power_user.arn
}

# ecspressoで、actions実行時に、s3のtfstateを参照できる権限
resource "aws_iam_role_policy" "s3" {
    name = "s3"
    role = aws_iam_role.deployer.id

    # 信頼ポリシー
    assume_role_policy = jsonencode(
        {
            "Version": "2012-10-17",
            "Statement":[
                {
                    "Effect":"Allow", # permission boundary
                    "Action":["s3:GetObject"],
                    "Resource": "arn:aws:s3:::tfstate保存用のs3バケット名/${local.system_name}/${local.env_name}/cicd/app_${local.service_name}_*.tfstate"
                },
            ]
        }
    )
    tags = {
      Name = "${local.name_prefix}-${local.service_name}-deployer"
    }
}

resource "aws_iam_role_policy" "ecs" {
    name = "ecs"
    role = aws_iam_role.deployer.id

    policy = jsonencode(
        {
            "Version": "2012-10-17",
            "Statement":[
                {
                    "sid": "RegisterTaskDefinition",
                    "Effect":"Allow", 
                    "Action":[
                        "ecs:RegisterTaskDefinition"
                    ],
                    "Resource": "*"
                },
                {
                    "sid": "PassRolesInTaskDefinition",
                    "Effect":"Allow", 
                    "Action":[
                        "iam:PassRole"
                    ],
                    "Resource": [
                        data.aws_iam_role.ecs_task.arn,
                        data.aws_iam_role.ecs_task_execution.arn,
                    ]
                },
                {
                    "sid": "DeployService",
                    "Effect":"Allow", 
                    "Action":[
                        "ecs:UpdateService",
                        "ecs:DescribeServices"
                    ],
                    "Resource": [
                        data.aws_ecs_service.this.arn
                    ]
                }
            ]
        }
    )
}