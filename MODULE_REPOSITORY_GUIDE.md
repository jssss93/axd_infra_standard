# 모듈 레포지토리 분리 가이드

이 문서는 현재 프로젝트의 모듈들을 별도의 Git 레포지토리로 분리하는 방법을 설명합니다.

## 분리 전략 옵션

### 옵션 1: 모든 모듈을 하나의 레포지토리로 통합 (권장)

**장점:**
- 모듈 간 의존성 관리가 쉬움
- 버전 관리가 단순함
- 하나의 레포지토리로 모든 모듈 관리 가능
- Terraform Registry에 등록하기 쉬움

**구조:**
```
terraform-azure-modules/
├── modules/
│   ├── foundation/
│   │   └── rg/
│   ├── networking/
│   │   ├── vnet/
│   │   ├── subnet/
│   │   ├── agw/
│   │   └── pe/
│   ├── compute/
│   │   ├── container-apps/
│   │   └── virtual-machines/
│   ├── data/
│   │   ├── acr/
│   │   ├── keyvault/
│   │   ├── cdb/
│   │   ├── postgres/
│   │   └── afterjob/
│   ├── services/
│   │   ├── foundry/
│   │   └── openai/
│   └── naming/
├── examples/
│   ├── basic/
│   ├── full-stack/
│   └── networking-only/
├── README.md
├── .gitignore
└── versions.tf
```

### 옵션 2: 카테고리별로 레포지토리 분리

**장점:**
- 모듈 그룹별로 독립적인 버전 관리
- 필요한 모듈만 클론 가능
- 팀별로 레포지토리 소유권 분리 가능

**구조:**
```
terraform-azure-foundation-modules/
terraform-azure-networking-modules/
terraform-azure-compute-modules/
terraform-azure-data-modules/
terraform-azure-services-modules/
terraform-azure-naming-module/
```

### 옵션 3: 각 모듈을 독립적인 레포지토리로 분리

**장점:**
- 모듈별 완전한 독립성
- 세밀한 버전 관리
- 모듈별 독립적인 CI/CD

**단점:**
- 레포지토리 관리 복잡도 증가
- 모듈 간 의존성 관리 어려움

## 권장 방법: 옵션 1 (통합 레포지토리)

### 1단계: 새 모듈 레포지토리 생성

```bash
# 새 디렉토리 생성
mkdir terraform-azure-modules
cd terraform-azure-modules

# Git 초기화
git init
git remote add origin <your-module-repo-url>
```

### 2단계: 모듈 파일 복사

현재 프로젝트에서 모듈만 복사:

```bash
# 현재 프로젝트에서 모듈 디렉토리 복사
cp -r /path/to/current/project/modules/* ./modules/

# .gitignore 복사 및 수정
cp /path/to/current/project/.gitignore ./.gitignore
```

### 3단계: 모듈 레포지토리 구조 생성

필요한 파일들:
- `README.md`: 모듈 사용법 및 설명
- `versions.tf`: Terraform 및 Provider 버전 정의
- `examples/`: 사용 예제
- `.gitignore`: Git 무시 파일

### 4단계: 기존 프로젝트에서 모듈 참조 변경

기존 프로젝트의 `main.tf`에서 로컬 경로 대신 Git 레포지토리 참조로 변경:

**변경 전:**
```hcl
module "rg" {
  source = "./modules/foundation/rg"
  # ...
}
```

**변경 후 (Git 레포지토리):**
```hcl
module "rg" {
  source = "git::https://github.com/your-org/terraform-azure-modules.git//modules/foundation/rg?ref=v1.0.0"
  # ...
}
```

**변경 후 (Terraform Registry):**
```hcl
module "rg" {
  source = "your-org/azure-modules/foundry/rg/azurerm"
  version = "~> 1.0"
  # ...
}
```

## 모듈 레포지토리 구조 예시

### 디렉토리 구조

```
terraform-azure-modules/
├── modules/
│   ├── foundation/
│   │   └── rg/
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       ├── outputs.tf
│   │       └── versions.tf
│   ├── networking/
│   │   ├── vnet/
│   │   ├── subnet/
│   │   ├── agw/
│   │   └── pe/
│   ├── compute/
│   │   └── container-apps/
│   ├── data/
│   │   ├── acr/
│   │   ├── keyvault/
│   │   ├── cdb/
│   │   ├── postgres/
│   │   └── afterjob/
│   ├── services/
│   │   ├── foundry/
│   │   └── openai/
│   └── naming/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── versions.tf
├── examples/
│   ├── basic/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── terraform.tfvars.example
│   ├── full-stack/
│   └── networking-only/
├── README.md
├── .gitignore
└── versions.tf
```

### README.md 예시

```markdown
# Terraform Azure Modules

재사용 가능한 Azure 인프라 모듈 컬렉션입니다.

## 모듈 목록

### Foundation
- `modules/foundation/rg`: Resource Group 모듈

### Networking
- `modules/networking/vnet`: Virtual Network 모듈
- `modules/networking/subnet`: Subnet 모듈
- `modules/networking/agw`: Application Gateway 모듈
- `modules/networking/pe`: Private Endpoints 모듈

### Compute
- `modules/compute/container-apps`: Container Apps 모듈

### Data
- `modules/data/acr`: Container Registry 모듈
- `modules/data/keyvault`: Key Vault 모듈
- `modules/data/cdb`: Cosmos DB 모듈
- `modules/data/postgres`: PostgreSQL 모듈

### Services
- `modules/services/foundry`: AI Foundry 모듈
- `modules/services/openai`: OpenAI 모듈

### Utilities
- `modules/naming`: 네이밍 규칙 모듈

## 사용 방법

### Git 레포지토리에서 직접 사용

```hcl
module "rg" {
  source = "git::https://github.com/your-org/terraform-azure-modules.git//modules/foundation/rg?ref=v1.0.0"
  
  name     = "my-resource-group"
  location = "koreacentral"
  tags     = {}
}
```

### Terraform Registry 사용 (등록 후)

```hcl
module "rg" {
  source  = "your-org/azure-modules/foundation/rg/azurerm"
  version = "~> 1.0"
  
  name     = "my-resource-group"
  location = "koreacentral"
  tags     = {}
}
```

## 버전 관리

이 레포지토리는 [Semantic Versioning](https://semver.org/)을 따릅니다:
- `v1.0.0`: 초기 릴리스
- `v1.1.0`: 새로운 기능 추가
- `v1.1.1`: 버그 수정
- `v2.0.0`: 주요 변경사항 (breaking changes)

## 예제

`examples/` 디렉토리에서 다양한 사용 예제를 확인할 수 있습니다.
```

### versions.tf 예시

```hcl
terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.40"
    }
  }
}
```

## 기존 프로젝트에서 모듈 참조 변경 스크립트

기존 프로젝트의 모든 모듈 참조를 자동으로 변경하는 스크립트:

```bash
#!/bin/bash

# 모듈 레포지토리 URL (예: GitHub)
MODULE_REPO_URL="git::https://github.com/your-org/terraform-azure-modules.git"
MODULE_VERSION="v1.0.0"

# main.tf 파일에서 모듈 참조 변경
sed -i.bak "s|source = \"./modules/|source = \"${MODULE_REPO_URL}//modules/|g" main.tf
sed -i.bak "s|//modules/\([^\"]*\)\"|//modules/\1?ref=${MODULE_VERSION}\"|g" main.tf

# env 디렉토리의 main.tf도 변경
find env -name "main.tf" -exec sed -i.bak "s|source = \"../modules/|source = \"${MODULE_REPO_URL}//modules/|g" {} \;
find env -name "main.tf" -exec sed -i.bak "s|source = \"../../modules/|source = \"${MODULE_REPO_URL}//modules/|g" {} \;
find env -name "main.tf" -exec sed -i.bak "s|//modules/\([^\"]*\)\"|//modules/\1?ref=${MODULE_VERSION}\"|g" {} \;

echo "모듈 참조가 변경되었습니다. .bak 파일을 확인하고 삭제하세요."
```

## 모듈 레포지토리 초기 설정 스크립트

새 모듈 레포지토리를 빠르게 설정하는 스크립트:

```bash
#!/bin/bash

# 모듈 레포지토리 디렉토리 생성
mkdir -p terraform-azure-modules/{modules,examples/{basic,full-stack,networking-only}}

# 현재 프로젝트에서 모듈 복사
cp -r modules/* terraform-azure-modules/modules/

# .gitignore 복사
cp .gitignore terraform-azure-modules/

# versions.tf 생성
cat > terraform-azure-modules/versions.tf <<EOF
terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.40"
    }
  }
}
EOF

echo "모듈 레포지토리 구조가 생성되었습니다."
```

## 다음 단계

1. 모듈 레포지토리 생성 및 초기 커밋
2. 기존 프로젝트에서 모듈 참조 변경
3. 테스트 및 검증
4. (선택) Terraform Registry에 등록
5. 문서화 및 예제 추가

## 주의사항

1. **버전 관리**: 모듈 변경 시 Semantic Versioning을 따르고 태그를 생성하세요.
2. **의존성**: 모듈 간 의존성이 있는 경우 문서화하세요.
3. **테스트**: 모듈 변경 후 예제를 통해 테스트하세요.
4. **문서화**: 각 모듈의 README.md를 작성하세요.
