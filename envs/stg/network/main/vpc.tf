resource "aws_vpc" "this" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true #private hostzoneでの名前解決
    enable_dns_support = true #private hostzoneでの名前解決

    tags = {
      "Name" = "${local.name_prefix}-main"
    }
}