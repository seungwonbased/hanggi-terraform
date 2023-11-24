# ☁️🔨 한끼얼마 CI/CD, Cloud Infra 자동화 구축 Report

## 1. Terraform S3, DynamoDB 백엔드 구성
### 1.1. Source Code

<a href="https://github.com/seungwonbased/hanggi-terraform/blob/main/backend.tf" target="_blank">🧾 [backend.tf] Source Code</a>

```terraform
resource "aws_s3_bucket" "terraform-backend" {  
  bucket = "hanggi-terraform-state-backend"  
  
  lifecycle {  
    prevent_destroy = false
  }  
}  
  
  
resource "aws_s3_bucket_versioning" "terraform-backend-versioning" {  
  bucket = aws_s3_bucket.terraform-backend.id  
  
  versioning_configuration {  
    status = "Enabled"  
  }  
}  

...
  
resource "aws_dynamodb_table" "terraform-state-lock" {  
  name         = "hanggi-terraform-state-lock"  
  billing_mode = "PAY_PER_REQUEST"  
  hash_key     = "LockID"  
  
  attribute {  
    name = "LockID"  
    type = "S"  
  }  
}  

...

```

- 테라폼의 백엔드로 S3를 구성
- S3의 버저닝을 Enable해 상태 파일의 버전을 관리할 수 있음
- DynamoDB를 Lock 파일 저장소로 사용

### 1.1. 결과

![[Screenshot 2023-11-24 at 11.07.25.png]]
- 상태 파일을 저장하는 버킷 생성



## 2. 