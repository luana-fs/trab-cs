# 1. A API HTTP (o "container")
resource "aws_apigatewayv2_api" "http_api" {
  name          = "lambda-cs-t1-api"
  protocol_type = "HTTP"
  description   = "API Gateway para a Lambda Spring Boot"
}

# 2. A "ponte" de integração com a Lambda
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.spring_lambda.invoke_arn # Puxa o ARN da sua Lambda
  payload_format_version = "2.0"
}

# 3. A Rota "Pega-Tudo" ($default)
resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "$default" # Envia todo o tráfego para a integração
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# 4. O "Stage" de deploy (publica a API)
resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default" # O stage padrão que é invocado no URL raiz
  auto_deploy = true

  # Garante que o stage só seja criado depois que a rota existir
  depends_on = [
    aws_apigatewayv2_route.default_route,
  ]
}

# 5. Permissão para a API invocar a Lambda
resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.spring_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # Limita a permissão apenas para esta API
  source_arn = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

# 6. Imprime o URL final no seu terminal
output "api_invoke_url" {
  description = "O URL de invocação para a API Gateway"
  value       = aws_apigatewayv2_api.http_api.api_endpoint
}