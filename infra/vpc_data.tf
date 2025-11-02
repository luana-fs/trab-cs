# Procura pela VPC padrão da sua conta nesta região
data "aws_vpc" "default" {
  default = true
}

# Procura por TODAS as subnets que existem dentro dessa VPC padrão
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
