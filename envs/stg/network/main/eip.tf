resource "aws_eip" "nat_gateway" {
    for_each = var.enable_nat_gateway ? local.nat_gateway_azs : {} #作成するかしないかを条件分岐で表現できる
    vpc = true
    tags = {
        Name = "${aws_vpc.this.tags.Name}-nat-gateway-${each.key}"
    }
    
}