# Output the API URLs for both stages
output "development_api_url" {
  value       = "${aws_api_gateway_deployment.development_deployment.invoke_url}"
  description = "The URL to invoke the API for the development stage"
}

output "staging_api_url" {
  value       = "${aws_api_gateway_deployment.staging_deployment.invoke_url}"
  description = "The URL to invoke the API for the staging stage"
}