# ☁️🔨 한끼얼마 배포, Cloud Infra 자동화 구축 Report

## 1. 프로젝트 소개

- 이전 프로젝트
	- [\[Flask SSR\] 한끼얼마](https://github.com/seungwonbased/ssg-recipe-project)
	- [\[Dockerizing\] 도커화된 한끼얼마](https://github.com/seungwonbased/dockerized-recipe-book)
	- [\[React\] 한끼얼마 Frontend](https://github.com/seungwonbased/ssgRecipeBook-react-frontend)
	- [\[Flask\] 한끼얼마 Restful API](https://github.com/seungwonbased/ssgRecipeBook-flask-backend)
	- [\[Kubernetes\] 한끼얼마 클러스터 구축 및 배포](https://github.com/seungwonbased/TIL/blob/main/%ED%95%9C%EB%81%BC%EC%96%BC%EB%A7%88%20K8s%20Cluster.md)

- 이전에 개발했던 한끼얼마 애플리케이션의 CI, CD 파이프라인을 구축
- AWS 아키텍처를 설계하고 구축
- 테라폼을 이용해 Infra as Code 구현

### 1.1. 프로젝트 멤버

- 배승원

### 1.2. 기술 스택

- Frontend
	- React
- Backend
	- Flask
- Infra
	- AWS
	- Terraform
- CI/CD
	- GitHub Action
	- ArgoCD

## 2. CI/CD Pipeline

![sc](https://github.com/seungwonbased/hanggi-terraform/tree/main/assets/cicd.png)

## 1. Terraform S3, DynamoDB 백엔드 구성
### 1.1. Backend Terraform Code

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

![sc](https://github.com/seungwonbased/hanggi-terraform/tree/main/assets/sc1.png)

- 상태 파일을 저장하는 버킷 생성

![sc](https://github.com/seungwonbased/hanggi-terraform/tree/main/assets/sc1.png)

- Lock 파일을 저장하는 테이블 생성

## 2. VPC, 서브넷 생성
### 2.1. VPC Terraform Code

> <a href="https://github.com/seungwonbased/hanggi-terraform/blob/main/modules/vpc/main.tf" target="_blank">🧾 [/modules/vpc/main.tf] Source Code</a>




> <a href="https://github.com/seungwonbased/hanggi-terraform/blob/main/modules/vpc/subnet/main.tf" target="_blank">🧾 [/modules/vpc/subnet/main.tf] Source Code</a>

