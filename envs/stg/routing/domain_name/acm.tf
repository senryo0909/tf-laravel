# domainに対する証明書の発行
resource "aws_acm_certificate" "root" {
    domain_name = data.aws_route53_zone.this.name

    validation_method = "DNS"

    tags = {
      "Name" = "${local.name_prefix}-appfoobar-link"
    }

    lifecycle {
      create_before_destroy = true
    }
}

# DNSの検証が完了したらapplyが完了する
resource "aws_acm_certificate_validation" "root" {
    certificate_arn = aws_acm_certificate.root.arn
}