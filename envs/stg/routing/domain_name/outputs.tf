# ALBの作成にあたっては、サブネットのIDとセキュリティグループのIDが必要のため作成

output "security_group_web_id" {
    value = aws_security_group.web.id
}
output "security_group_vpc_id" {
    value = aws_security_group.vpc.id
}
output "subnet_public" {
    value = aws_subnet.public
}

# ecs.tfがtarget_groupのarnを参照できるようにする
output "lb_target_group_foobar_arn" {
    value = aws_lb_target_group.foobar.arn
}

