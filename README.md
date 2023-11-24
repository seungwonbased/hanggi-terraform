# ☁️🔨 한끼얼마 배포, Cloud Infra 자동화 구축 Report

## 1. 프로젝트 소개

- 이전 프로젝트
	- [\[Flask SSR\] 한끼얼마](https://github.com/seungwonbased/ssg-recipe-project)
	- [\[Dockerizing\] 도커화된 한끼얼마](https://github.com/seungwonbased/dockerized-recipe-book)
	- [\[React\] 한끼얼마 Frontend](https://github.com/seungwonbased/ssgRecipeBook-react-frontend)
	- [\[Flask\] 한끼얼마 Restful API](https://github.com/seungwonbased/ssgRecipeBook-flask-backend)
	- [\[Kubernetes\] 한끼얼마 클러스터 구축 및 배포](https://github.com/seungwonbased/TIL/blob/main/%ED%95%9C%EB%81%BC%EC%96%BC%EB%A7%88%20K8s%20Cluster.md)

- 이전에 개발했던 한끼얼마 애플리케이션의 CI, CD 파이프라인을 구축
- AWS 아키텍처를 설계
- Terraform을 이용해 Infra as Code 구현

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
	- GitHub Actions
	- ArgoCD

## 2. CI/CD Pipeline

![sc](https://github.com/seungwonbased/hanggi-terraform/blob/main/assets/cicd.png)

- 개발자가 리포지토리에 Push만 하면 구성된 인프라에 자동으로 배포됨

### 2.1. Frontend 배포 파이프라인

1. GitHub 리포지토리에 Push
2. 변경 사항이 생기면 GitHub Actions가 React 애플리케이션을 빌드 후 S3에 업로드해 정적 웹 호스팅

### 2.2. Backend 배포 파이프라인

1. GitHub 리포지토리에 Push
2. 변경 사항이 생길 시 Git Actions 동작
	1. Flask 애플리케이션을 도커 이미지로 빌드 후 AWS ECR로 Push
	2. seungwonbased/cicd-argocd 리포지토리의 버전 태그 업데이트
3. ArgoCD가 seungwonbased/cicd-argocd 리포지토리를 감시하고 있다가 버전 태그가 업데이트되면 EKS에 Sync 알림 전달
	1. 개발자의 코드를 한 번 검토하고 배포하고 싶을 경우 Manual, 자동으로 배포하고 싶을 경우 Autosync
4. EKS가 Sync를 전달받으면 ECR에 해당 버전이 태그되어 있는 이미지를 이용해 새로운 Deployment 생성

### 2.3. Discord 알림

1. Frontend 혹은 Backend 리포지토리의 Git Actions 동작
2. Webhook을 통해 빌드 및 배포 성공 여부를 Discord에 메시지 전송

## 3. Infra Architecture

![sc](https://github.com/seungwonbased/hanggi-terraform/blob/main/assets/infra.png)

- S3 버킷에 Frontend 애플리케이션을 호스팅해 비용 효율적
- EC2 Bastion Host를 하나 띄워 프라이빗 서브넷에 있는 데이터베이스와 SSH 터널링
	- 터널링을 통해 데이터베이스 관리
- 두 개의 AZ에 Kubernetes 클러스터, DB 클러스터를 구축해 고가용성 확보
- EKS를 사용한 관리형 Kubenetes 인프라 구축
	- 로컬 머신에 Kubernetes 콘솔을 구성해 kubectl 명령으로 관리 가능
- ECR의 프라이빗 리포지토리 사용

## 4. Infrastructure as Code

- 한 번의 `terraform apply` 명령으로 인스턴스, 클러스터, 역할 등의 모든 AWS 리소스 배포
- Terraform 코드를 모듈화하여 유지보수를 용이하게 하고 가독성을 높임

> 주요 리소스 생성 과정

### 4.1. Terraform S3, DynamoDB 백엔드 구성
#### 4.1.1. Backend Terraform Code

<a href="https://github.com/seungwonbased/hanggi-terraform/blob/main/backend.tf" target="_blank">🧾 [backend.tf] 전체 Source Code</a>

```hcl
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

#### 4.1.2. 결과

![sc](https://github.com/seungwonbased/hanggi-terraform/blob/main/assets/sc1.png)

- 상태 파일을 저장하는 버킷 생성

![sc](https://github.com/seungwonbased/hanggi-terraform/blob/main/assets/sc2.png)

- Lock 파일을 저장하는 테이블 생성

### 4.2. VPC, 서브넷 생성
#### 4.2.1. VPC, Subnet Terraform Code

> <a href="https://github.com/seungwonbased/hanggi-terraform/blob/main/modules/vpc/main.tf" target="_blank">🧾 [/modules/vpc/main.tf] 전체 Source Code</a>

> <a href="https://github.com/seungwonbased/hanggi-terraform/blob/main/modules/vpc/subnet/main.tf" target="_blank">🧾 [/modules/vpc/subnet/main.tf] 전체 Source Code</a>

- 본 모듈에서 선언한 리소스
	- VPC
	- Subnet
	- Internet Gateway
	- Route Table
	- Elastic IP
- CIDR 블록, VPC 이름, 리전은 변수로 설정해 `terraform apply` 명령 시 입력하도록 함

#### 4.2.2. 결과

![sc](https://github.com/seungwonbased/hanggi-terraform/blob/main/assets/sc3.png)

![sc](https://github.com/seungwonbased/hanggi-terraform/blob/main/assets/sc4.png)

### 4.3. ECR 생성
#### 4.3.1. ECR Terraform Code

> <a href="https://github.com/seungwonbased/hanggi-terraform/blob/main/modules/ecr/main.tf" target="_blank">🧾 [/modules/ecr/main.tf] 전체 Source Code</a>

- Backend 애플리케이션 도커 이미지가 저장될 리포지토리 선언

#### 4.3.2. 결과

![sc](https://github.com/seungwonbased/hanggi-terraform/blob/main/assets/sc5.png)

### 4.4. 정적 웹 호스팅을 위한 S3 생성
#### 4.4.1. S3 Terraform Code

> <a href="https://github.com/seungwonbased/hanggi-terraform/blob/main/modules/ecr/main.tf" target="_blank">🧾 [/modules/ecr/main.tf] 전체 Source Code</a>

```hcl
resource "aws_s3_bucket" "s3-static-web-server" {  
  bucket = "hanggi-static-web-server"  
}  

...

resource "aws_s3_bucket_acl" "s3-static-web-server" {  
  depends_on = [  
    aws_s3_bucket_ownership_controls.s3-static-web-server,  
    aws_s3_bucket_public_access_block.s3-static-web-server,  
  ]  
  
  bucket = aws_s3_bucket.s3-static-web-server.id  
  acl    = "public-read"  
}  
  
...

```

- 정적 웹 호스팅을 위해 S3의 ACL 공개 읽기 권한을 설정

#### 4.4.2. 결과

![sc](https://github.com/seungwonbased/hanggi-terraform/blob/main/assets/sc6.png)

![sc](https://github.com/seungwonbased/hanggi-terraform/blob/main/assets/sc7.png)

## 5. RDS 생성
### 5.1. RDS Terraform Code

```hcl
resource "aws_db_subnet_group" "rds-subnet-group" {  
  name = "rds-subnet-group"  
  subnet_ids = [  
    var.subnet_1_id,  
    var.subnet_2_id  
  ]  
}  
  
  
resource "aws_db_instance" "hanggi-rds" {  
  allocated_storage = 5  
  max_allocated_storage = 20  
  availability_zone = "us-west-2b"  
  vpc_security_group_ids = [ var.sg_id ]  
  db_subnet_group_name = aws_db_subnet_group.rds-subnet-group.name  
  engine = "postgres"  
  engine_version = "15.4"  
  instance_class = "db.t3.micro"  
  skip_final_snapshot = true  
  identifier = "recipe-rds"  
  db_name = var.db_name  
  username = var.db_username  
  password = var.db_password  
  port = "5432"  
}
```

#### 5.1.1. Issue: Option Combination Error

- RDS를 생성할 때는 옵션의 조합을 잘 봐야 함
- 처음에 프리 티어 사용을 위해 t2.micro 인스턴스를 선택
	- 고가용성을 위해 Multi-AZ로 DB를 구성할 경우 t2 시리즈는 지원하지 않음
- t3.micro 인스턴스를 사용해 해결

### 5.2. 결과

![sc](https://github.com/seungwonbased/hanggi-terraform/blob/main/assets/sc8.png)

## 6. EKS 클러스터, 노드 생성
### 6.1. EKS Terraform Code

```hcl
resource "aws_eks_cluster" "hanggi-eks-cluster" {  
  name     = "hanggi-eks-cluster"  
  role_arn = var.role_arn  
  version = "1.28"  
  
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]  
  
  vpc_config {  
    security_group_ids = [ var.eks_cluster_sg_id ]  
    subnet_ids         = [ var.eks_subnet_1_id, var.eks_subnet_2_id ]  
    endpoint_private_access = true  
    endpoint_public_access = true  
  }  
}  
  
  
resource "aws_eks_node_group" "eks-nodes" {  
  cluster_name  = aws_eks_cluster.hanggi-eks-cluster.name  
  node_group_name = "eks-nodes"  
  node_role_arn = var.role_arn  
  subnet_ids    = [ var.eks_subnet_1_id, var.eks_subnet_2_id ]  
  instance_types = [ "t3.small" ]  
  disk_size = 20  
  ami_type = "AL2_x86_64"  
  
  scaling_config {  
    desired_size = 3  
    max_size     = 4  
    min_size     = 2  
  }  
}
```

#### 6.1.1. Issue: Unsupported AMI

- Amazon Linux 계열이 아니면 호환을 백프로 보장해주지는 않는듯 함
- 호환되는 Amazon Linux를 명시해 해결

### 6.2. 결과

![sc](https://github.com/seungwonbased/hanggi-terraform/blob/main/assets/sc9.png)

![sc](https://github.com/seungwonbased/hanggi-terraform/blob/main/assets/sc10.png)

