resource "aws_subnet" "public" {
    for_each = var.azs #map型を指定でき、繰り返しリソースの作成が可能

    availability_zone = "${data.aws_region.current.name}${each.key}" # ex) ${ap-northeast-1}${a} = ap-northeast-1a
    cidr_block = each.value.public_cidr
    map_public_ip_on_launch = true
    vpc_id = aws_vpc.this.id #同階層であれば別ファイルの出力結果を取得できる

    tags = {
        Name = "{aws_vpc.this.tags.Name}-public-${each.key}"
    }
}

resource "aws_subnet" "private" {
    for_each = var.azs

    availability_zone = "${data.aws_region.current.name}${each.key}"
    cidr_block = each.value.private_cidr
    map_public_ip_on_launch = false
    vpc_id = aws_vpc.this.id #同階層であれば別ファイルの出力結果を取得できる
}