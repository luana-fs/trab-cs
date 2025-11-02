resource "aws_security_group" "rds_sg" {
  name        = "rds-postgres-sg"
  description = "Allow inbound traffic from Lambda to RDS"
  vpc_id      = data.aws_vpc.default.id 

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    
    # Substitui 'cidr_blocks' por 'security_groups'
    security_groups = [aws_security_group.lambda_sg.id] 
  }

  # Permite que o RDS envie tráfego de VOLTA para a Lambda
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Pode ser "0.0.0.0/0" ou o CIDR da VPC
  }

  tags = {
    Name = "rds-postgres-sg"
  }
}

resource "aws_security_group" "lambda_sg" {
  name        = "lambda-vpc-sg"
  description = "Security group for Lambda function and VPC Endpoints"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    self      = true # Permite tráfego vindo do próprio grupo
  }

  # Permite que a Lambda acesse a internet/Endpoints na porta 443
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  tags = {
    Name = "lambda-sg"
  }
}
