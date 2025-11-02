resource "aws_lambda_function" "spring_lambda" {
  function_name = "lambda-cs-t1-springboot"
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.lambda_repo.repository_url}:latest"
  timeout       = 30
  memory_size   = 1024
  role          = "arn:aws:iam::843483113908:role/LabRole"

  vpc_config {
    # Usa o ID do novo security group
    security_group_ids = [aws_security_group.lambda_sg.id]
    
    # Usa todas as subnets da sua VPC Padrão
    subnet_ids         = data.aws_subnets.default.ids
  }
}


