# Define um Security Group para o RDS
resource "aws_security_group" "rds_sg" {
  name        = "rds-postgres-sg"
  description = "Allow inbound traffic for RDS Postgres"
  vpc_id      = data.aws_vpc.default.id # Usa a VPC Padrão existente

  # Exemplo de regra de entrada (inbound)
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # Permite tráfego da sua VPC
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [data.aws_vpc.default.cidr_block] # Permite tráfego da VPC Padrão
  }

  tags = {
    Name = "rds-postgres-sg"
  }
}

resource "aws_security_group" "lambda_sg" {
  name        = "lambda-vpc-sg"
  description = "Security group for Lambda function"
  vpc_id      = data.aws_vpc.default.id

  # Permite que a Lambda aceda à Internet (necessário para o ECR, logs, etc.)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
