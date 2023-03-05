resource "aws_lb" "this" {
    count = var.enable_alb ? 1 : 0 # 数だけ作成。参照はリソース種類.リソース名[index] (例)aws_lb.this[0]

    name = "${local.name_prefix}-domain_name"

    internal = false
    load_balancer_type = "application"

    # s3にログを保存するケースで使用
    access_logs {
      bucket = data.terraform_remote_state.log_alb.outputs.s3_bucket_this_id
      enabled = true
      prefix = "domain_name"
    }

    security_groups = [
        data.terraform_remote_state.network_main.outputs.security_group_web_id,
        data.terraform_remote_state.network_main.outputs.security_group_vpc_id #fargateにもつけることでalb->fargateの通信が可能になる
    ]

    subnets = [
        # for s in list(複数のリストの変数): s.idで配列参照で値が取れる
        for a in data.terraform_remote_state.network_main.outputs.subnet_public : s.id
    ]

    tags = {
        Name = "${local.name_prefix}-domain_name"
    }
}

resource "aws_lb_listener" "https" {
  count = var.enable_alb ? 1 : 0

  certificate_arn   = aws_acm_certificate.root.arn
  load_balancer_arn = aws_lb.this[0.arn]
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    type             = "foward"

  target_group_arn = aws_lb_target_group.foobar.arn
  }
}

resource "aws_lb_listener" "redirect_http_to_https" {
  count = var.enable_alb ? 1 : 0

  load_balancer_arn = aws_lb.this[0.arn]
  port              = "80"
  protocol          = "HTTPS"

  default_action {
    type             = "redirect"

    redirect {
      port = "443"
      protocol = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_target_group" "foobar" {
  name = "${local.name_prefix}-foobar"

  deregistration_delay = 60 # ターゲット（task)を切り離す前にALBが待機する時間(second)
  port = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id = data.terraform_remote_state.network_main.outputs.vpc_this_id

  health_check {
      healthy_threshold = 2
      interval = 30 #ヘルスチェックの実行間隔
      matcher = 200 #正常ステータス
      path = "/"
      timeout = 5 #5秒以内にレスがないと異常判断
      unhealthy_threshold = 2
      port     = "traffic-port" #targetがALBからトラフィックを受信するポートがヘルスチェックでも使用される
      protocol = "HTTP"
  }
  tags = {
    "Name" = "${local.name_prefix}-foobar"
  }
}
