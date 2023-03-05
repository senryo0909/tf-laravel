variable "vpc_cidr" {
    type = string
    default = "172.31.0.0/16"
}

variable "azs" {
    type = map(object({
        public_cidr = string 
        private_cidr = string
    }))
    default = {
        a = {
            public_cidr = "172.31.0.0/20"
            private_cidr = "172.31.48.0/20"
            },
        c = {
            public_cidr = "172.31.16.0/20" 
            private_cidr = "172.31.64.0/20"
        }
    }
}

# NatGatawayは料金が高いので、terraform apply時に引数をboolで渡すことで柔軟に作成・非作成を行う
# terraform apply -var='enable_nat_gateway=true' => 作成される
variable "enable_nat_gateway" {
    type = bool
    default = false
}
# multiple AZの関係で、最低２つ必要だが、料金問題で、一つ作成をデフォルトとしたい
variable "single_nat_gateway" { 
    type = bool
    default = true
}

