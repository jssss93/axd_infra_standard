# 환경별 배포 가이드

이 디렉토리는 환경별로 인프라를 배포하기 위한 설정 파일들을 포함합니다.

## 구조

```
environments/
├── dev/
│   ├── main.tf              # 루트 모듈 호출
│   ├── variables.tf          # 환경별 변수 정의
│   ├── terraform.tfvars      # 환경별 변수 값 (git에 커밋하지 않음)
│   ├── terraform.tfvars.example  # 변수 예시 파일
│   ├── backend.tf            # Backend 설정 (선택적)
│   └── backend.tf.example    # Backend 설정 예시
├── staging/
│   └── ...
└── prod/
    └── ...
```

## 사용 방법

### 1. 환경별 변수 파일 생성

각 환경 디렉토리에서 `terraform.tfvars.example`를 참고하여 `terraform.tfvars` 파일을 생성합니다:

```bash
cd environments/dev
cp terraform.tfvars.example terraform.tfvars
# terraform.tfvars 파일을 편집하여 실제 값 입력
```

**중요 설정:**
- `subscription_id`: 배포할 Azure Subscription ID를 지정합니다. 지정하지 않으면 기본 subscription이 사용됩니다.
- 네이밍 규칙 변수: `project_name`, `environment`, `purpose` 등은 자동 네이밍에 사용됩니다.

**주의**: `terraform.tfvars` 파일은 민감한 정보를 포함할 수 있으므로 `.gitignore`에 추가되어 있습니다.

### 2. Backend 설정 (선택적)

원격 상태 관리를 위해 `backend.tf` 파일을 생성합니다:

```bash
cp backend.tf.example backend.tf
# backend.tf 파일을 편집하여 실제 Backend 설정 입력
```

또는 `terraform init` 시 `-backend-config` 옵션을 사용할 수 있습니다:

```bash
terraform init -backend-config=backend.tfvars
```

### 3. Terraform 초기화 및 실행

```bash
# 개발 환경
cd environments/dev
terraform init
terraform plan
terraform apply

# 스테이징 환경
cd ../staging
terraform init
terraform plan
terraform apply

# 프로덕션 환경
cd ../prod
terraform init
terraform plan
terraform apply
```

## 환경별 차이점

각 환경은 다음과 같은 차이점을 가질 수 있습니다:

- **리소스 이름**: 환경 접두사 포함 (예: `rg-dev-myproject`, `rg-prod-myproject`)
- **네트워크 주소 공간**: 환경별로 다른 CIDR 블록 사용
- **리소스 크기**: 개발 환경은 작은 크기, 프로덕션은 큰 크기
- **복제본 수**: 개발 환경은 최소 복제본, 프로덕션은 고가용성 구성
- **태그**: 환경별 태그 자동 적용

## 보안 고려사항

1. **상태 파일 분리**: 각 환경은 별도의 Backend를 사용하여 상태 파일을 분리합니다.
2. **권한 관리**: 환경별로 다른 Azure Service Principal 또는 Managed Identity 사용 권장
3. **변수 파일**: `terraform.tfvars` 파일은 `.gitignore`에 포함되어 있어 커밋되지 않습니다.

## CI/CD 통합

각 환경 디렉토리는 독립적으로 배포할 수 있으므로, CI/CD 파이프라인에서 다음과 같이 구성할 수 있습니다:

```yaml
# 예시: GitHub Actions
- name: Deploy Dev
  run: |
    cd environments/dev
    terraform init
    terraform apply -auto-approve

- name: Deploy Staging (requires approval)
  run: |
    cd environments/staging
    terraform init
    terraform apply -auto-approve

- name: Deploy Prod (requires approval)
  run: |
    cd environments/prod
    terraform init
    terraform apply -auto-approve
```
