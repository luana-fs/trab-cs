# --- ADICIONE OS BLOCOS A SEGUIR ---

# 1. CRIE O API GATEWAY (Tipo HTTP, mais simples e barato)
resource "aws_apigatewayv2_api" "lambda_api" {
  name          = "springboot-http-api"
  protocol_type = "HTTP"
  # Aponta para a sua função Lambda já existente
  target        = aws_lambda_function.spring_lambda.arn
}

# 2. CRIE A ROTA PADRÃO (Opcional, mas recomendado)
# Isto faz com que TODAS as chamadas (ex: /users, /) vão para a Lambda.
# Se preferir, pode remover isto e definir rotas específicas.
resource "aws_apigatewayv2_route" "default_route" {
  api_id = aws_apigatewayv2_api.lambda_api.id

  # "$default" captura todas as requisições
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# 3. CRIE A INTEGRAÇÃO (A "cola" entre a API e a Lambda)
# (Necessário se usar a rota $default acima)
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id = aws_apigatewayv2_api.lambda_api.id
  
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.spring_lambda.invoke_arn
  payload_format_version = "2.0" # Importante para o aws-serverless-java-container
}

# 4. CRIE O "STAGE" (Faz o "deploy" da API e dá-lhe uma URL)
resource "aws_apigatewayv2_stage" "default_stage" {
  api_id = aws_apigatewayv2_api.lambda_api.id
  name   = "$default" # Cria a URL base sem sufixo (como /Prod)
  
  auto_deploy = true
}

# 5. DÊ PERMISSÃO (Permite que o API Gateway chame a sua Lambda)
resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.spring_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # Garante que SÓ esta API Gateway possa chamar a função
  source_arn = "${aws_apigatewayv2_api.lambda_api.execution_arn}/*/*"
}

# 6. IMPRIMA A URL (Para que a veja no final da pipeline)
output "api_invoke_url" {
  description = "URL de invocação da API Gateway"
  value       = aws_apigatewayv2_stage.default_stage.invoke_url
}