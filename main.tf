# Create the REST API
resource "aws_api_gateway_rest_api" "my_rest_api" {
  name        = "socket2"
  description = "This is etc development and staging gateway."
}

# Create a Resource under the API
resource "aws_api_gateway_resource" "my_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.my_rest_api.id
  parent_id   = aws_api_gateway_rest_api.my_rest_api.root_resource_id
  path_part   = "etc-rest-dev"  # This will be the path /etc-rest-dev
}

# Create a GET Method for the Resource
resource "aws_api_gateway_method" "get_method" {
  rest_api_id   = aws_api_gateway_rest_api.my_rest_api.id
  resource_id   = aws_api_gateway_resource.my_api_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# Create a Mock Integration (no Lambda or backend integration)
resource "aws_api_gateway_integration" "get_integration" {
  rest_api_id = aws_api_gateway_rest_api.my_rest_api.id
  resource_id = aws_api_gateway_resource.my_api_resource.id
  http_method = aws_api_gateway_method.get_method.http_method
  type        = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }

  integration_http_method = "GET"
}

# Create a 200 Response for the GET Method
resource "aws_api_gateway_method_response" "get_method_response" {
  rest_api_id = aws_api_gateway_rest_api.my_rest_api.id
  resource_id = aws_api_gateway_resource.my_api_resource.id
  http_method = aws_api_gateway_method.get_method.http_method
  status_code = "200"
}

# Create Integration Response for the Mock Integration
resource "aws_api_gateway_integration_response" "get_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.my_rest_api.id
  resource_id = aws_api_gateway_resource.my_api_resource.id
  http_method = aws_api_gateway_method.get_method.http_method
  status_code = aws_api_gateway_method_response.get_method_response.status_code
}

# Deploy the API to the 'development' stage
resource "aws_api_gateway_deployment" "development_deployment" {
  depends_on = [
    aws_api_gateway_integration.get_integration
  ]
  rest_api_id = aws_api_gateway_rest_api.my_rest_api.id
  stage_name  = "development"  # Stage name for development
}

# Deploy the API to the 'staging' stage
resource "aws_api_gateway_deployment" "staging_deployment" {
  depends_on = [
    aws_api_gateway_integration.get_integration
  ]
  rest_api_id = aws_api_gateway_rest_api.my_rest_api.id
  stage_name  = "staging"  # Stage name for staging
}
