# README

## Overview

Data platform to ingest asset data from trading 212

## Domain

- Data Engineering
- Data Analysis
- Development Operations

## Glossary

- Block syntax
- Block Types
- Declarative
- HCL
- Heredoc syntax (`<<EOF ..Text EOF`)
- IAC
- Idempotency
- Local Blocks
- Lock file
- Output Blocks
- Resource Block
- Terraform Data Sources
- Terraform Plan Symbols
- Provider Block
- Provider plugin
- Source control
- State data
- Terraform Block
- Terraform
- Variable Blocks
- Write, Plan, Apply

## TODO

- [x] POC step function - Set up on AWS console
- [x] Remove s3 event triggers
- [ ] Document architecural change
- [ ] Update Terraform
- [ ] POC observability - cloud watch log, metrics and alarms

## Project Management

**Board:** [Project Board](https://github.com/users/akin-mustapha/projects/13)

**Use Case:**

**Architecture:**

**Design:**

## Architecture

![alt text](<./docs/img/architecture-diagram-v2.jpg>)

### Tech Stack

- Event Schedular
- Lambda
- S3
- Glue Python Shell Job
- Glue Data Catalog
- Athena
- Grafana
- Python

## Design

**Design Here:**

## Setup and Installations

### Terraform Installation

[Terraform Docs](https://developer.hashicorp.com/terraform/docs)
[Step Function IAC](https://docs.aws.amazon.com/step-functions/latest/dg/terraform-sfn.html)

```txt
brew install tfenv
tfenv install latest
tfenv use latest
```

**Pin verson:** Update `terraform/environments/dev/main.tf`

**Set up State:**

```txt
# Versioned, private S3 bucket for state files
aws s3api create-bucket \
  --bucket t212-terraform-state-861580917950 \
  --region eu-west-1 \
  --create-bucket-configuration LocationConstraint=eu-west-1

aws s3api put-bucket-versioning \
  --bucket t212-terraform-state-861580917950 \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption \
  --bucket t212-terraform-state-861580917950 \
  --server-side-encryption-configuration '{
    "Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]
  }'

aws s3api put-public-access-block \
  --bucket t212-terraform-state-861580917950 \
  --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

```

**Add Backend:**

**Initialize terraform:**

```txt
  cd terraform/environments/dev
  terraform init 
```

### Setup Step Function

- Create a State machine
- Specify flow in GUI
- Specify Role, allow lambda invocation, SNS Publish
- Add Event Bridge Schedule
- Add identity role access to execute a state machine (policy, role)

### Setup Grafana for Cloud Watch Metric

#### Configure Assumed Role for Grafana

1. Create new role on AWS
2. Attach `AmazonGrafanaCloudWatchAccess` policy

#### Add new Data Source

1. Add assumed role ARN to data source - `arn:aws:iam::861580917950:role/grafana-assumed-role`

```txt
1. CloudWatch metrics query failed: operation error CloudWatch: ListMetrics, https response error StatusCode: 403, RequestID: ceeac963-7b2d-41b3-aab2-3f7e57ae044b, api error AccessDenied: UnknownError 2. CloudWatch logs query failed: operation error CloudWatch Logs: DescribeLogGroups, https response error StatusCode: 400, RequestID: ec45db2b-04ce-4c22-a974-26772a337a43, api error AccessDeniedException: User: arn:aws:iam::008923505280:user/aws-temp-creds-prod-eu-west-6-grafana-datasources is not authorized to perform: logs:DescribeLogGroups on resource: arn:aws:logs:eu-west-1:008923505280:log-group::log-stream: because no identity-based policy allows the logs:DescribeLogGroups action
```

```txt
1. CloudWatch metrics query failed: operation error CloudWatch: ListMetrics, get identity: get credentials: failed to refresh cached credentials, operation error STS: AssumeRole, https response error StatusCode: 403, RequestID: 73f91367-d0e6-4889-88f2-f4bce2246546, api error AccessDenied: User: arn:aws:iam::008923505280:user/aws-temp-creds-prod-eu-west-6-grafana-datasources is not authorized to perform: sts:AssumeRole on resource: arn:aws:iam::861580917950:role/grafana-assumed-role 

2. CloudWatch logs query failed: operation error CloudWatch Logs: DescribeLogGroups, get identity: get credentials: failed to refresh cached credentials, operation error STS: AssumeRole, https response error StatusCode: 403, RequestID: ed7f67d2-fce0-478f-9a22-e71b296643aa, api error AccessDenied: User: arn:aws:iam::008923505280:user/aws-temp-creds-prod-eu-west-6-grafana-datasources is not authorized to perform: sts:AssumeRole on resource: arn:aws:iam::861580917950:role/grafana-assumed-role  
```

## Troubleshooting / Incident Fix

### Incident 1

#### 38 DCA Market Order Place on a single run

`t212-dca` fired multiple trade. Issue linked to s3 event. Given that multiple files can be written to s3 per a single consumption of the API endpoint, this triggers the automated dca process multiple times.

#### Fix

- Add a lock to dca script. Check that asset hasn't been purchased within a suitable time interval.
- Orchestrate workflow using `Aws Step Function`
