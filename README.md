# Terraform Azure Infrastructure Modules

이 프로젝트는 Azure의 Resource Group, Virtual Network, Subnet, Container Apps를 모듈화하여 관리하는 Terraform 구성입니다.

## 구조

```
.
├── modules/              # 재사용 가능한 모듈
│   ├── rg/              # Resource Group 모듈
│   ├── network/         # Network 모듈 (VNet + Subnets 통합)
│   └── compute/         # Compute 모듈 (Container Apps)
├── environments/         # 환경별 배포 설정
│   ├── dev/            # 개발 환경
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars.example
│   │   └── backend.tf.example
│   ├── staging/        # 스테이징 환경
│   └── prod/           # 프로덕션 환경
├── main.tf              # 루트 모듈 (직접 사용 또는 environments에서 호출)
├── variables.tf         # 루트 레벨 변수
├── locals.tf            # 공통 태그 및 로컬 변수
├── outputs.tf           # 루트 레벨 출력
├── versions.tf          # Terraform 및 Provider 버전
└── README.md
```

## 사용 방법

### 방법 1: 환경별 디렉토리 사용 (권장)

환경별로 독립적인 배포를 위해 `environments/` 디렉토리를 사용합니다:

```bash
# 개발 환경 배포
cd environments/dev
cp terraform.tfvars.example terraform.tfvars
# terraform.tfvars 파일 편집 (subscription_id 포함)
terraform init
terraform plan
terraform apply

# 스테이징/프로덕션 환경도 동일한 방식으로 배포
```

**중요**: `terraform.tfvars` 파일에 `subscription_id`를 지정하면 해당 subscription에 배포됩니다. 지정하지 않으면 기본 subscription이 사용됩니다.

자세한 내용은 [environments/README.md](environments/README.md)를 참조하세요.

### 방법 2: 루트 디렉토리에서 직접 사용

루트 디렉토리에서 직접 사용할 수도 있습니다:

```bash
# 1. 초기화
terraform init

# 2. 계획 확인
terraform plan

# 3. 적용
terraform apply
```

### 4. 변수 커스터마이징

`terraform.tfvars` 파일을 생성하여 변수를 커스터마이징할 수 있습니다:

```hcl
resource_group_name = "rg-myproject-prod"
location            = "koreacentral"
vnet_name          = "vnet-myproject-prod"
vnet_address_space = ["10.1.0.0/16"]

subnets = {
  app = {
    name             = "subnet-app"
    address_prefixes = ["10.1.1.0/24"]
  }
  db = {
    name             = "subnet-db"
    address_prefixes = ["10.1.2.0/24"]
  }
}

container_app_environment_name = "cae-myproject-prod"
container_apps_subnet_id      = "app"  # 위에서 정의한 subnet 키

container_apps = {
  webapp = {
    name         = "webapp"
    image        = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
    cpu          = 0.5
    memory       = "1.0Gi"
    min_replicas = 1
    max_replicas = 3
    env_vars = {
      ENVIRONMENT = "production"
    }
    ingress = {
      external_enabled = true
      target_port      = 80
    }
  }
}

# 공통 태그 (모든 리소스에 자동 적용)
common_tags = {
  Environment = "production"
  Project     = "myproject"
  Team        = "platform"
}

# 추가 태그 (선택적)
tags = {
  CostCenter = "engineering"
}
```

## 모듈 설명

### Resource Group 모듈 (`modules/rg/`)

Azure Resource Group을 생성합니다.

**입력 변수:**
- `name`: 리소스 그룹 이름
- `location`: Azure 지역
- `tags`: 태그 맵

**출력:**
- `id`: 리소스 그룹 ID
- `name`: 리소스 그룹 이름
- `location`: 리소스 그룹 위치

### Network 모듈 (`modules/network/`)

Azure Virtual Network와 Subnet을 통합하여 관리하는 모듈입니다. VNet과 Subnet은 강한 의존성 관계가 있으므로 하나의 모듈로 묶어 관리합니다.

**입력 변수:**
- `name`: 가상 네트워크 이름
- `resource_group_name`: 리소스 그룹 이름
- `location`: Azure 지역
- `address_space`: 주소 공간 (CIDR 리스트)
- `dns_servers`: DNS 서버 IP 주소 리스트 (선택)
- `subnets`: 서브넷 설정 맵
- `tags`: 태그 맵

**서브넷 설정 옵션:**
- `name`: 서브넷 이름
- `address_prefixes`: 주소 접두사 리스트
- `network_security_group_id`: NSG ID (선택, 별도 association 리소스로 연결)
- `route_table_id`: 라우트 테이블 ID (선택, 별도 association 리소스로 연결)
- `service_endpoints`: 서비스 엔드포인트 리스트 (선택)
- `service_endpoint_policy_ids`: 서비스 엔드포인트 정책 ID 리스트 (선택)
- `delegation`: 서브넷 위임 설정 (선택)

**출력:**
- `vnet_id`: 가상 네트워크 ID
- `vnet_name`: 가상 네트워크 이름
- `vnet_address_space`: 주소 공간
- `subnet_ids`: 서브넷 키와 ID 맵
- `subnet_names`: 서브넷 키와 이름 맵
- `subnets`: 서브넷 객체 맵

### Compute 모듈 (`modules/compute/`)

Azure Container Apps를 관리하는 모듈입니다. Container App Environment와 여러 Container App을 생성할 수 있습니다.

**입력 변수:**
- `resource_group_name`: 리소스 그룹 이름
- `location`: Azure 지역
- `container_app_environment_name`: Container App Environment 이름
- `infrastructure_subnet_id`: Container Apps Environment용 서브넷 ID (선택)
- `log_analytics_workspace_id`: 기존 Log Analytics Workspace ID (선택, 없으면 생성)
- `log_analytics_retention_days`: Log Analytics 보존 기간 (일)
- `container_apps`: Container App 설정 맵
- `tags`: 태그 맵

**Container App 설정 옵션:**
- `name`: Container App 이름
- `image`: 컨테이너 이미지
- `cpu`: CPU 할당량 (기본값: 0.25)
- `memory`: 메모리 할당량 (기본값: "0.5Gi")
- `min_replicas`: 최소 복제본 수 (기본값: 0)
- `max_replicas`: 최대 복제본 수 (기본값: 10)
- `revision_mode`: 리비전 모드 (기본값: "Single")
- `env_vars`: 환경 변수 맵
- `secrets`: 시크릿 리스트
- `ingress`: 인그레스 설정 (외부 접근, 타겟 포트 등)
- `tags`: 태그 맵

**출력:**
- `log_analytics_workspace_id`: Log Analytics Workspace ID
- `container_app_environment_id`: Container App Environment ID
- `container_app_environment_name`: Container App Environment 이름
- `container_app_ids`: Container App ID 맵
- `container_app_fqdns`: Container App FQDN 맵
- `container_apps`: Container App 객체 맵

## 태그 관리

이 프로젝트는 공통 태그를 자동으로 모든 리소스에 적용합니다:

- **자동 태그**: `ManagedBy = "Terraform"`, `CreatedDate` (생성 날짜)
- **공통 태그** (`common_tags`): 환경, 프로젝트, 팀 등 모든 리소스에 공통으로 적용되는 태그
- **추가 태그** (`tags`): 리소스별로 추가로 적용할 수 있는 태그

태그는 다음 순서로 병합됩니다:
1. 자동 태그 (locals.common_tags)
2. 공통 태그 (var.common_tags)
3. 추가 태그 (var.tags)

나중에 정의된 태그가 이전 태그를 덮어씁니다.

## 네이밍 규칙

이 프로젝트는 표준화된 네이밍 규칙을 지원합니다. 형식은 다음과 같습니다:

**기본 형식:** `{프로젝트}-{환경}-{용도/기능}-{자산관리(선택)}-{리소스명}-{순번(선택)}`

### 리소스별 네이밍 규칙

| 리소스 타입 | 네이밍 형식 | 예시 |
|------------|------------|------|
| Resource Group | `{프로젝트}-{환경}-{용도/기능}-rg` | `tmp-dev-agent-rg` |
| Virtual Network | `{프로젝트}-{환경}-{용도/기능}-vnet` | `tmp-dev-agent-vnet` |
| Subnet | `{프로젝트}-{환경}-{용도/기능}-{자산관리}-sbn` | `tmp-dev-agent-cae-sbn` (subnets 맵의 키가 자산관리로 사용됨) |
| Container Apps Environment | `{프로젝트}-{환경}-{용도/기능}-cae-{순번}` | `tmp-dev-agent-cae-001` |
| Container Apps | `{프로젝트}-{환경}-{용도/기능}-aca-{순번}` | `tmp-dev-search-aca-001` |

### 네이밍 구성 요소

- **프로젝트** (필수): 프로젝트 이름 (예: `tmp`)
- **환경** (필수): 환경 이름 (예: `dev`, `staging`, `prod`, `nw`, `devops`)
- **용도/기능** (필수): 리소스의 용도 (예: `main`, `dns`, `agent`, `cicd`, `search`, `nl2sql`, `chatbot`, `front`, `backend`)
- **자산관리** (선택): 자산 관리 식별자 (예: `resolver`, `pe`, `gitlab`, `runner`, `agw`, `cae`, `vm`, `aca`)
- **리소스명** (필수): 리소스 타입 약어 (예: `rg`, `vnet`, `sbn`, `cae`, `aca`)
- **순번** (선택): 순차 번호 (예: `001`, `002`)

### 사용 방법

환경별 디렉토리에서 네이밍 규칙 변수를 설정하면 자동으로 네이밍이 적용됩니다:

```hcl
# terraform.tfvars
project_name    = "tmp"
environment     = "dev"
purpose         = "agent"
asset_management = "cae"
sequence_number  = "001"
```

리소스 이름을 직접 지정하고 싶은 경우, 해당 변수를 설정하면 네이밍 규칙을 우회합니다:

```hcl
resource_group_name          = "custom-rg-name"
vnet_name                    = "custom-vnet-name"
container_app_environment_name = "custom-cae-name"
```

## 요구사항

- Terraform >= 1.0
- Azure Provider ~> 4.40
- Azure CLI 또는 Service Principal 인증 설정 필요

## 참고 자료

- [Terraform Azure Provider 공식 문서](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Resource Group 리소스](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group)
- [Azure Virtual Network 리소스](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network)
- [Azure Subnet 리소스](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet)
- [Azure Container Apps 리소스](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app)
# axd_infra_standard
