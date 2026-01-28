#!/bin/bash

# 모듈 레포지토리 준비 스크립트
# 사용법: ./scripts/prepare-module-repo.sh [출력 디렉토리]

set -e

# 출력 디렉토리 설정 (기본값: ../terraform-azure-modules)
OUTPUT_DIR="${1:-../terraform-azure-modules}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=========================================="
echo "모듈 레포지토리 준비 스크립트"
echo "=========================================="
echo "프로젝트 루트: $PROJECT_ROOT"
echo "출력 디렉토리: $OUTPUT_DIR"
echo ""

# 출력 디렉토리 생성
mkdir -p "$OUTPUT_DIR"
cd "$OUTPUT_DIR"
OUTPUT_ABS="$(pwd)"

echo "1. 디렉토리 구조 생성 중..."
mkdir -p modules
mkdir -p examples/{basic,full-stack,networking-only}

# 모듈 복사
echo "2. 모듈 파일 복사 중..."
cp -r "$PROJECT_ROOT/modules/"* "$OUTPUT_ABS/modules/" 2>/dev/null || {
    echo "경고: modules 디렉토리를 찾을 수 없습니다."
}

# .gitignore 복사 및 수정
echo "3. .gitignore 파일 생성 중..."
if [ -f "$PROJECT_ROOT/.gitignore" ]; then
    cp "$PROJECT_ROOT/.gitignore" "$OUTPUT_ABS/.gitignore"
else
    cat > "$OUTPUT_ABS/.gitignore" <<'EOF'
# Local .terraform directories
**/.terraform/*

*.tfplan
*.tfplan.*
*.tfstate
*.tfstate.*

# Crash log files
crash.log
crash.*.log

# Exclude all .tfvars files
*.tfvars
*.tfvars.json

# Ignore override files
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Ignore CLI configuration files
.terraformrc
terraform.rc

# OS files
.DS_Store
Thumbs.db
EOF
fi

# versions.tf 생성
echo "4. versions.tf 파일 생성 중..."
cat > "$OUTPUT_ABS/versions.tf" <<'EOF'
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

# 기본 README.md 생성
echo "5. README.md 파일 생성 중..."
cat > "$OUTPUT_ABS/README.md" <<'EOF'
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
- `modules/data/afterjob`: Key Vault Secrets 모듈

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

### 로컬 경로에서 사용 (개발 중)

```hcl
module "rg" {
  source = "../terraform-azure-modules/modules/foundation/rg"
  
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

## 기여하기

1. 이 레포지토리를 포크하세요
2. 기능 브랜치를 생성하세요 (`git checkout -b feature/amazing-feature`)
3. 변경사항을 커밋하세요 (`git commit -m 'Add amazing feature'`)
4. 브랜치에 푸시하세요 (`git push origin feature/amazing-feature`)
5. Pull Request를 생성하세요
EOF

# 기본 예제 생성
echo "6. 기본 예제 생성 중..."
cat > "$OUTPUT_ABS/examples/basic/main.tf" <<'EOF'
# 기본 예제: Resource Group 생성
module "rg" {
  source = "../../modules/foundation/rg"
  
  name     = "rg-example-basic"
  location = "koreacentral"
  tags = {
    Environment = "example"
    ManagedBy   = "Terraform"
  }
}
EOF

cat > "$OUTPUT_ABS/examples/basic/README.md" <<'EOF'
# 기본 예제

이 예제는 Resource Group을 생성하는 가장 간단한 사용법을 보여줍니다.

## 실행 방법

```bash
cd examples/basic
terraform init
terraform plan
terraform apply
```
EOF

echo ""
echo "=========================================="
echo "완료!"
echo "=========================================="
echo "모듈 레포지토리가 준비되었습니다: $OUTPUT_ABS"
echo ""
echo "다음 단계:"
echo "1. cd $OUTPUT_ABS"
echo "2. git init"
echo "3. git remote add origin <your-repo-url>"
echo "4. git add ."
echo "5. git commit -m 'Initial commit: Azure modules'"
echo "6. git tag v1.0.0"
echo "7. git push -u origin main"
echo "8. git push origin v1.0.0"
echo ""
