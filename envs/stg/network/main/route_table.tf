# 各public subnetで使用
resource "aws_route_table" "router" {
    vpc_id = aws_vpc.this.id
    
    tags = {
        Name = "${aws_vpc.this.tags.Name}public"
    }
}

# routetableのroutetableレコードにinternet gatawayを紐づける
resource "aws_route" "internet_gateway_public" {
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
    route_table_id = aws_route_table.router.id
}

# subnetの紐付け
resource "aws_route_table_associaction" "public" {
    for_each = var.azs

    route_table_id = aws_route_table.router.id
    subnet_id = aws_subnet.public[each.key].id # 全public subnetを紐づける
}

resource "aws_route_table" "private" {
    for_each = var.azs
    vpc_id = aws_vpc.this.id
    tags = { 
        Name = "${aws_vpc.this.tags.Name}-private-${each.key}"
    }
}
resource "aws_route" "nat_gateway_private" {
    for_each = var.enable_nat_gateway ? var.azs:{}
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[var.single_nat_gateway ? keys(var.azs)[0] : each.key].id
    route_table_id = aws_route_table.private[each.key].id
}

resource "aws_route_table_association" "private" {
    for_each = var.azs
    route_table_id = aws_route_table.private[each.key].id
    subnet_id = aws_subnet.private[each.key].id
}
