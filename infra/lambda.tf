resource "aws_lambda_function" "spring_lambda" {
  function_name = "lambda-cs-t1-springboot"
  package_type  = "Image"
  image_uri = "843483113908.dkr.ecr.us-east-1.amazonaws.com/cs-t1-springboot-repo:latest"
  timeout       = 30
  memory_size   = 1024
  role          = "arn:aws:iam::843483113908:role/LabRole"

  architectures = ["x86_64"]

  lifecycle {
    ignore_changes = [
      image_uri,
      # last_modified, 
    ]
  }
}


