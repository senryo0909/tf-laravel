resource "aws_s3_bucket" "this" {
    bucket= "${local.name_prefix}-alb-log"
    
    server_side_encryption_configuration {
        rule {
            apply_server_side_encryption_by_default {
                sse_algorithm="AES256"
            }
        }
    }

    tags = {
        Name = "${local.name_prefix}-alb-log"
    }

    lifecycle_rule {
        enabled = true

        expiration { 
            days = "90"
        }
    }
}

resource "aws_s3_bucket_policy" "this" {
    bucket = aws_s3_bucket.this.id
    policy = jsonencode(
    {
        "Version": "20121017",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "AWS": "arn:aws:iam::${data.aws_elb_service_account.current.id}:root" #data.tfよりawsからデータ取得
                },
                "Action": "s3:PutObject",
                "Resource":"arn:aws:s3:::${aws_s3_bucket.this.id}/*"
            },
            {
                "Effect": "Allow",
                "Principal": { 
                    "Service": "delivery.logs.amazonaws.com"
                },
                "Action": "s3:PutObject",
                "Resource":"arn:aws:s3:::${aws_s3_bucket.this.id}/*",
                "Condition":{
                    "StringEquals":{
                        "s3:xamzacl": "bucketownerfullcontrol"
                    }
                }
            },
            {
                "Effect":"Allow",
                "Principal":{
                    "Service":"delivery.logs.amazonaws.com"
                },
                "Action":"s3:GetBucketAcl",
                "Resource":"arn:aws:s3:::${aws_s3_bucket.this.id}"
            }
        ]
    })
}
