# targetグループ作成に利用
output "vpc_this_id" {
    value = aws_vpc.this.id
}


output "subnet_public" {
    value = aws_subnet.public
}
# ecsはprivate_subnetで運用し、ecs.tfがservice作成時に参照できるように
output "subnet_private" {
    value = aws_subnet.private
}

output "security_group_vpc_id" {
    value = aws_security_group.vpc.id
}

# RDSのセキュリティーグループ
output "security_group_db_foobar_id" {
    value = aws_security_group.db_foobar.id
}
# RDSのサブネットグループ（private)
output "db_subnet_group_this_id" {
    value = aws_db_subnet_group.this.id
}