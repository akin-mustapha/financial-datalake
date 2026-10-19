# ReadMe

**Overview:** Data pipeline to ingest asset data from trading 212

Tech Stack

- Event Schedular
- Lambda
- S3
- Glue Python Shell Job
- Glue Data Catalog
- Athena
- Grafana
- Python

## Architecture

![alt text](<./docs/img/architecture-diagram.jpg>)

## Terraform installation

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

**Add backedn:**

**Initialize terraform:**

```txt
  cd terraform/environments/dev
  terraform init 
```

## Troubleshooting

### Multiple DCA Market Other

`t212-dca` fired multiple trade. Issue linked to s3 event. Given that multiple files can be written to s3 per a single consumption of the API endpoint, this triggers the automated dca process multiple times.

#### fix

- Add a lock to dca script. Check that asset hasn't been purchased within a suitable time interval.
- Orchestrate workflow using `step function`

#### TODO

-[] POC step function - Set up on AWS console
-[] Remove s3 event triggers
-[] Document architecural change
-[] Update Terraform