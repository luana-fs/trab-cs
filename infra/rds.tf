resource "aws_db_instance" "postgres" {
  identifier              = "rds-postgres-academy"
  engine                  = "postgres"
  instance_class          = var.db_instance_class
  allocated_storage       = 20
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  skip_final_snapshot     = true
  publicly_accessible     = false
  
  # Referencie o novo Security Group criado acima
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name

  tags = {
    Name = "RDS-Postgres-Academy"
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "rds-subnet-group-academy"
  subnet_ids  = data.aws_subnets.default.ids
  description = "DB subnet group for the RDS instance"

  tags = {
    Name = "rds-subnet-group"
  }
}