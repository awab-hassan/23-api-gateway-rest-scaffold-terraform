# API Gateway REST API — Two-Stage Scaffold

Minimal Terraform module that stands up an **AWS API Gateway REST API** (v1) with a single `GET /etc-rest-dev` resource backed by a MOCK integration, deployed simultaneously to `development` and `staging` stages. Used at etc as a placeholder API (for CORS, routing, DNS attachment) while the real Lambda backends were wired in later — the MOCK integration returns a 200 immediately, so the rest of the stack (DNS, CloudFront, consumers) can be built before the business logic exists.

## Highlights

- **MOCK integration** — returns `{"statusCode": 200}` directly from API Gateway without ever invoking a backend. Useful for contract-first development and for verifying DNS / CloudFront / custom domain setups before any Lambda code exists.
- **Two-stage deploy in one apply** — both `development` and `staging` stages come up together; outputs expose both invoke URLs.
- **v1 (REST), not v2 (HTTP)** — demonstrates the classic REST API resource / method / integration / deployment / response model (chose v1 deliberately when fine-grained request/response mapping was anticipated).
- **Companion CLI reference** — `lambda-cli-examples.txt` catalogues the `aws lambda create-function` commands used to deploy the sibling WebSocket Lambdas (`send_data_socket_copy`, `socket_disconnectConnection_copy`), handy for redeploys without Terraform.

## Architecture

```
 Client → GET /etc-rest-dev
        → API Gateway REST API "socket2"
        → MOCK integration
        → 200 { "statusCode": 200 }

 Stages: /development  and  /staging  (both deployed from the same definition)
```

## Tech stack

- **Terraform** >= 1.x, AWS provider
- **AWS services:** API Gateway v1 (REST)
- **Region:** `ap-northeast-1` (Tokyo)

## Repository layout

```
APIGATEWAY_CODE/
├── README.md
├── .gitignore
├── apigateway.tf              # API, resource, GET method, MOCK integration, 2 stages
└── lambda-cli-examples.txt    # Reference AWS CLI commands for related Lambdas
```

## How it works

1. `aws_api_gateway_rest_api` creates the API named `socket2` with description "This is etc development and staging gateway."
2. `aws_api_gateway_resource` adds a path part `etc-rest-dev` under the root.
3. `aws_api_gateway_method` defines `GET` with `authorization = NONE`.
4. `aws_api_gateway_integration` wires a MOCK integration with a static request template that sets `statusCode = 200`.
5. Method response and integration response both declare a `200` status.
6. Two `aws_api_gateway_deployment` resources deploy the API to `development` and `staging` stages.
7. Outputs expose both invoke URLs.

## Prerequisites

- Terraform >= 1.x
- AWS CLI configured with permissions for `apigateway:*`
- An AWS account that can host API Gateway in `ap-northeast-1`

## Deployment

```bash
terraform init
terraform plan
terraform apply
```

Outputs:
- `development_api_url` — `https://<api-id>.execute-api.ap-northeast-1.amazonaws.com/development`
- `staging_api_url` — `https://<api-id>.execute-api.ap-northeast-1.amazonaws.com/staging`

Test either stage:

```bash
curl "https://<api-id>.execute-api.ap-northeast-1.amazonaws.com/development/etc-rest-dev"
# → {"statusCode": 200}
```

## Teardown

```bash
terraform destroy
```

## Notes

- To replace the MOCK with a real Lambda, change the `type = "MOCK"` in `aws_api_gateway_integration` to `"AWS_PROXY"` and add `uri = <lambda_invoke_arn>` plus an `aws_lambda_permission`.
- The API and resource names (`socket2`, `etc-rest-dev`) are placeholder strings from a real deployment — rename before re-use.
- Demonstrates: API Gateway v1 REST primitives (resource/method/integration/deployment/response), MOCK integrations as a scaffolding technique, multi-stage deployment from a single definition.
