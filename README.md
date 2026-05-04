# Project # 23 - api-gateway-rest-scaffold-terraform

Minimal Terraform module that provisions an AWS API Gateway REST API (v1) with a single `GET` resource backed by a MOCK integration, deployed simultaneously to `development` and `staging` stages. Useful as a contract-first scaffold: lets you stand up DNS, CloudFront, and downstream consumers against a working endpoint before backend Lambdas exist.

## How It Works

```
Client
   |
   | GET /<resource-path>
   v
API Gateway REST API
   |
   v
MOCK integration
   |
   v
HTTP 200 { "statusCode": 200 }

Stages: /development and /staging (both deployed from the same definition)
```

Provisioning steps in `apigateway.tf`:

1. `aws_api_gateway_rest_api` creates the REST API.
2. `aws_api_gateway_resource` adds a path resource under the root.
3. `aws_api_gateway_method` defines `GET` with `authorization = NONE`.
4. `aws_api_gateway_integration` wires a MOCK integration with a request template that returns `statusCode = 200`.
5. Method and integration responses both declare a `200` status.
6. Two `aws_api_gateway_deployment` resources deploy to `development` and `staging`.
7. Outputs expose both invoke URLs.

## Prerequisites

- Terraform >= 1.x
- AWS credentials with `apigateway:*` permissions

## Deployment

```bash
terraform init
terraform plan
terraform apply
```

Outputs:

- `development_api_url`
- `staging_api_url`

Test:

```bash
curl "https://<api-id>.execute-api.ap-northeast-1.amazonaws.com/development/<resource-path>"
# Returns: {"statusCode": 200}
```

## Teardown

```bash
terraform destroy
```

## Notes

- To replace the MOCK with a real Lambda backend: change `type = "MOCK"` in `aws_api_gateway_integration` to `"AWS_PROXY"`, add `uri = <lambda_invoke_arn>`, and create an `aws_lambda_permission` granting API Gateway invoke access.
- API and resource names in this module are placeholders. Rename them in `apigateway.tf` before reuse.
- v1 REST API was chosen over v2 HTTP API for fine-grained request and response template support. v2 is generally preferred for new projects unless those mappings are required.
- `lambda-cli-examples.txt` is a reference of `aws lambda create-function` commands used during related deployments. Useful for manual redeploys outside Terraform.
