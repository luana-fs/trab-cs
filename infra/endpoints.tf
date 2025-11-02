# 1. Endpoint para a API do ECR (necessário para "docker login", etc.)
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = data.aws_vpc.default.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.api" # 'var.aws_region' deve ser sua variável de região
  vpc_endpoint_type   = "Interface"
  
  # Associa às mesmas subnets da Lambda
  subnet_ids          = data.aws_subnets.default.ids 
  
  # Associa ao mesmo Security Group da Lambda
  security_group_ids  = [aws_security_group.lambda_sg.id] 
  private_dns_enabled = true
}

# 2. Endpoint para o "Docker" do ECR (necessário para "docker pull/push")
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = data.aws_vpc.default.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  
  subnet_ids          = data.aws_subnets.default.ids
  security_group_ids  = [aws_security_group.lambda_sg.id]
  private_dns_enabled = true
}

# 3. Endpoint para o S3 (necessário porque as camadas do ECR são armazenadas no S3)
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = data.aws_vpc.default.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  
  # Endpoints do tipo Gateway se anexam à tabela de rotas da VPC
  route_table_ids = [data.aws_vpc.default.main_route_table_id]
}