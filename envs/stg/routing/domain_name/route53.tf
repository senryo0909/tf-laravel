data "aws_route53_zone" "this" {
    name = "write-your-domain-name.com"
}

# 証明書のドメイン所有権の検証　CNAMEを登録する必要があり、以下は定形
resource "aws_route53_record" "certificate_validation" {
    # aws provider ver.3^の書き方
    for_each = { 
        for dvo in aws_acm_certificate.root.domain_validation_options : dvo.domain_name => {
            name = dvo.resource_record_name
            type = dvo.resource_record_type
            record = dvo.resource_record_value
        }
    }
    name = each.value.name 
    records = [each.value.record]
    ttl = 60
    type = each.value.type
    zone_id = data.aws_route53_zone.this.id
}

# ALBのALIASレコード作成

resource "aws_route53_record" "root_a" {
  count   = var.enable_alb ? 1 : 0

  name    = data.aws_route53_zone.this.name # レコード名
  type    = "A"
  zone_id = data.aws_route53_zone.this.zone_id # ホストゾーン

  alias {
    evaluate_target_health = true
    name                   = aws_lb.this[0].dns_name
    zone_id                = aws_lb.this[0].zone_id
  }
}