# Terraform Azure Infrastructure Modules

이 프로젝트는 Azure 인프라를 모듈화하여 관리하는 Terraform 구성입니다. Resource Group, Virtual Network, Container Apps, Application Gateway, 그리고 다양한 PaaS 서비스들을 지원합니다.

## 구조

```
.
├── modules/                    # 재사용 가능한 모듈
│   ├── foundation/            # 기본 인프라
│   │   └── rg/               # Resource Group 모듈
│   ├── networking/            # 네트워크 관련
│   │   ├── vnet/             # Virtual Network 모듈
│   │   ├── subnet/           # Subnet 모듈
│   │   ├── agw/                  # Application Gateway 모듈
│   │   └── pe/               # Private Endpoints + Private DNS Zones 통합
│   ├── compute/              # 컴퓨팅 리소스
│   │   └── container-apps/   # Container Apps, VM, Log Analytics
│   ├── data/                 # 데이터 저장소 서비스들
│   │   ├── acr/              # Container Registry
│   │   ├── keyvault/         # Key Vault
│   │   ├── cosmos/           # Cosmos DB
│   │   └── postgres/         # PostgreSQL
│   └── services/             # AI 서비스들
│       ├── foundry/          # AI Foundry
│       └── openai/           # OpenAI
├── env/                       # 환경별 배포 설정
│   ├── dev/                  # 개발 환경
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars.example
│   │   └── backend.tf.example
│   ├── staging/              # 스테이징 환경
│   └── prod/                 # 프로덕션 환경
├── main.tf                    # 루트 모듈 (직접 사용 또는 env에서 호출)
├── variables.tf               # 루트 레벨 변수
├── locals.tf                  # 공통 태그 및 로컬 변수
├── outputs.tf                # 루트 레벨 출력
├── versions.tf                # Terraform 및 Provider 버전
└── README.md
```

## 사용 방법

### 방법 1: 환경별 디렉토리 사용 (권장)

환경별로 독립적인 배포를 위해 `env/` 디렉토리를 사용합니다:

```bash
# 개발 환경 배포
cd env/dev
cp terraform.tfvars.example terraform.tfvars
# terraform.tfvars 파일 편집 (subscription_id 포함)
terraform init
terraform plan
terraform apply

# 스테이징/프로덕션 환경도 동일한 방식으로 배포
```

**중요**: `terraform.tfvars` 파일에 `subscription_id`를 지정하면 해당 subscription에 배포됩니다. 지정하지 않으면 기본 subscription이 사용됩니다.

자세한 내용은 [env/README.md](env/README.md)를 참조하세요.

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
# 네이밍 규칙 변수 (자동 네이밍 사용 시)
project_name    = "tmp"
environment     = "dev"
purpose         = "agent"
asset_management = "cae"
sequence_number  = "001"

# 또는 직접 이름 지정
resource_group_name = "rg-myproject-prod"
location            = "koreacentral"
vnet_name          = "vnet-myproject-prod"
vnet_address_space = ["10.1.0.0/16"]

subnets = {
  agw = {
    address_prefixes = ["10.1.1.0/27"]  # Application Gateway용
  }
  cae = {
    address_prefixes = ["10.1.1.32/27"]  # Container Apps Environment용
  }
  vm = {
    address_prefixes = ["10.1.1.64/27"]  # Virtual Machine용
  }
  pe = {
    address_prefixes = ["10.1.1.224/27"]  # Private Endpoint용
  }
}

# Container Apps
container_app_environment_name = "cae-myproject-prod"
container_apps_subnet_id      = "cae"  # 위에서 정의한 subnet 키

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

# Application Gateway
application_gateway_enabled = true
application_gateway_subnet_id = "agw"
application_gateway_config = {
  sku_name = "Standard_v2"
  capacity = 2
}

# PaaS 서비스들
container_registry_enabled = true
key_vault_enabled = true
cosmos_db_enabled = true
postgresql_enabled = true

# Private Endpoints
private_endpoints_enabled = true
private_endpoint_subnet_id = "pe"

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

## 배포 순서

Terraform은 리소스 간 의존성을 자동으로 감지하여 올바른 순서로 배포합니다. 다음은 실제 배포 순서입니다:

### 배포 순서 개요

```
1. Resource Group (Foundation)
   ↓
2. Networking Core (VNet + Subnets) ─┐
   ↓                                 │ (병렬 배포 가능)
3. Infrastructure Services (PaaS) ───┘
   ├─ Data Services (Key Vault, ACR, Cosmos, PostgreSQL)
   └─ AI Services (Foundry, OpenAI)
   ↓
4. Afterjob (Key Vault Secrets 생성)
   ↓
5. Compute (Container Apps + VMs)
   ↓
6. Application Gateway (Container Apps FQDN 자동 연결)
   ↓
7. Private Endpoints (선택사항)
```

### 단계별 상세 설명

#### 1단계: Resource Group 생성
- **모듈**: `module.rg`
- **의존성**: 없음 (최상위 리소스)
- **생성 시간**: ~5초
- **생성 리소스**: Resource Group

#### 2단계: Virtual Network 생성
- **모듈**: `module.vnet`
- **의존성**: `module.rg` (Resource Group)
- **생성 시간**: ~10초
- **생성 리소스**:
  - Virtual Network

#### 3단계: Subnets 생성
- **모듈**: `module.subnets`
- **의존성**: `module.vnet` (Virtual Network)
- **생성 시간**: ~20초
- **생성 리소스**:
  - Subnets (agw, cae, vm, pe 등)
  - Network Security Group Associations
  - Route Table Associations

#### 4단계: Infrastructure Services 생성 (병렬 가능)
- **모듈**: `module.data` (Key Vault, ACR, Cosmos, PostgreSQL), `module.services` (Foundry, OpenAI)
- **의존성**: `module.rg` (Resource Group)
- **생성 시간**: 서비스별로 다름 (각 2-10분)
- **생성 리소스** (활성화된 경우):
  - **Data Services** (`module.data`):
    - Key Vault (다른 서비스보다 먼저 생성)
    - Container Registry (ACR)
    - Cosmos DB
    - PostgreSQL
  - **AI Services** (`module.services`, `depends_on = [module.data]`):
    - AI Foundry Hub → Project → Cognitive Account → 모델 배포
    - OpenAI Cognitive Account → 모델 배포

**AI Foundry 배포 순서:**
1. Storage Account 생성 (또는 기존 사용)
2. Foundry Hub 생성
3. Foundry Project 생성
4. Project Cognitive Services Account 생성
5. 모델 배포 (Project Account에 배포)

이 단계는 Networking과 병렬로 배포될 수 있습니다.

#### 5단계: Key Vault Secrets 생성 (Afterjob)
- **모듈**: `module.afterjob`
- **의존성**: 
  - `module.data` (모든 Data 서비스)
  - `module.services` (모든 AI 서비스)
- **생성 시간**: ~30초-1분
- **생성 리소스**:
  - Key Vault Secrets (모든 서비스의 연결 정보를 Key Vault에 저장)
    - ACR: login-server, admin-username, admin-password
    - Cosmos DB: endpoint, primary-key, secondary-key
    - PostgreSQL: fqdn, admin-login, password
    - Foundry: endpoint
    - OpenAI: endpoint, primary-key, secondary-key

**중요**: 이 단계는 모든 서비스가 생성된 후에 실행되며, Container Apps에서 사용할 Secret ID를 생성합니다.

#### 6단계: Compute 리소스 생성
- **모듈**: `module.compute`
- **의존성**: 
  - `module.rg` (Resource Group)
  - `module.subnets` (Subnet ID)
  - `module.data` (Key Vault ID - 명시적 `depends_on`)
  - `module.afterjob` (Key Vault Secret IDs - `key_vault_secrets` 변수)
- **생성 시간**: ~5-10분
- **생성 리소스**:
  - Log Analytics Workspace (없는 경우)
  - Container App Environment
  - Container Apps (FQDN 자동 생성, Key Vault Secrets 사용)
  - Virtual Machines (선택사항)

**중요**: Container Apps는 `module.afterjob`에서 생성된 Key Vault Secret IDs를 사용하여 Secret을 참조합니다.

#### 7단계: Application Gateway 생성
- **모듈**: `module.networking` 내부의 `module.agw`
- **의존성**: 
  - `module.subnets` (Subnet ID)
  - `module.compute` (Container Apps FQDN)
- **생성 시간**: ~10-15분
- **생성 리소스**:
  - Public IP (선택사항)
  - Application Gateway
  - Backend Pool에 Container Apps FQDN 자동 연결

**참고**: Application Gateway는 Container Apps의 FQDN이 생성된 후에 배포됩니다. `module.networking` 내부에서 처리되지만, 실제 생성은 Compute 이후에 이루어집니다.

#### 8단계: Private Endpoints 생성 (선택사항)
- **모듈**: `module.networking` 내부의 `module.pe`
- **의존성**: 
  - `module.rg` (Resource Group)
  - `module.networking` (VNet ID, Subnet ID)
  - `module.data` (모든 Data 서비스 리소스 ID)
  - `module.services` (모든 AI 서비스 리소스 ID)
- **생성 시간**: ~5-10분
- **생성 리소스** (활성화된 경우):
  - Private DNS Zones
  - Private Endpoints (Key Vault, Cosmos DB, PostgreSQL, ACR)

### 예상 전체 배포 시간

| 단계 | 리소스 | 예상 시간 |
|------|--------|----------|
| 1단계 | Resource Group | ~5초 |
| 2단계 | Virtual Network | ~10초 |
| 3단계 | Subnets | ~20초 |
| 4단계 | Infrastructure Services (PaaS) | ~2-10분 (서비스별) |
| 5단계 | Key Vault Secrets (Afterjob) | ~30초-1분 |
| 6단계 | Container Apps Environment + Apps | ~5-10분 |
| 7단계 | Application Gateway | ~10-15분 |
| 8단계 | Private Endpoints (선택사항) | ~5-10분 |
| **전체** | **모든 리소스** | **~20-35분** |

### 배포 순서 확인 방법

```bash
# Terraform이 감지한 의존성 그래프 확인
terraform graph | dot -Tsvg > graph.svg

# 또는 텍스트 형식으로 확인
terraform graph
```

### 단계별 배포 (선택사항)

필요한 경우 단계별로 배포할 수 있습니다:

```bash
# 1단계: Resource Group만 생성
terraform apply -target=module.rg

# 2단계: Virtual Network만 생성
terraform apply -target=module.vnet

# 3단계: Subnets만 생성
terraform apply -target=module.subnets

# 4단계: Infrastructure Services만 생성
terraform apply -target=module.data -target=module.services

# 5단계: Key Vault Secrets만 생성
terraform apply -target=module.afterjob

# 6단계: Compute만 생성
terraform apply -target=module.compute

# 7단계: Application Gateway만 생성 (networking 모듈 내부)
terraform apply -target=module.networking.module.agw

# 8단계: Private Endpoints만 생성 (networking 모듈 내부)
terraform apply -target=module.networking.module.pe

# 전체 배포
terraform apply
```

### 주의사항

1. **Container Apps FQDN 대기**: Application Gateway는 Container Apps의 FQDN이 생성된 후에 배포됩니다.
2. **Key Vault Secrets 의존성**: Container Apps 모듈은 `module.afterjob`에서 생성된 Key Vault Secret IDs를 사용합니다. 따라서 Afterjob 모듈이 먼저 완료되어야 합니다.
3. **Afterjob 모듈**: 모든 서비스(Data + AI Services)가 생성된 후에 Key Vault Secrets를 생성합니다. 이는 Container Apps에서 Secret을 참조하기 위해 필요합니다.
4. **Private Endpoints 의존성**: Private Endpoints는 모든 PaaS 서비스들이 생성된 후에 배포됩니다.
5. **Application Gateway 배포 시간**: Application Gateway는 가장 오래 걸리는 리소스입니다 (10-15분).
6. **모듈 구조**: 모든 리소스는 루트 `main.tf`에서 개별 모듈로 직접 호출됩니다.
7. **Secret 참조**: Container Apps에서 Key Vault Secret을 사용하는 경우, `secrets` 블록에 정의된 `secret_name`이 `module.afterjob.key_vault_secret_ids`의 키와 일치해야 합니다.

## 모듈 설명

### Foundation 모듈

#### Resource Group 모듈 (`modules/foundation/rg/`)

Azure Resource Group을 생성합니다.

**입력 변수:**
- `name`: 리소스 그룹 이름
- `location`: Azure 지역
- `tags`: 태그 맵

**출력:**
- `id`: 리소스 그룹 ID
- `name`: 리소스 그룹 이름
- `location`: 리소스 그룹 위치

### Networking 모듈

#### VNet 모듈 (`modules/networking/vnet/`)

Azure Virtual Network를 관리하는 모듈입니다.

**입력 변수:**
- `name`: 가상 네트워크 이름
- `resource_group_name`: 리소스 그룹 이름
- `location`: Azure 지역
- `address_space`: 주소 공간 (CIDR 리스트)
- `dns_servers`: DNS 서버 IP 주소 리스트 (선택)
- `tags`: 태그 맵

**출력:**
- `id`: 가상 네트워크 ID
- `name`: 가상 네트워크 이름
- `address_space`: 주소 공간

#### Subnet 모듈 (`modules/networking/subnet/`)

Azure Subnet을 관리하는 모듈입니다. 여러 Subnet을 map으로 관리합니다.

**입력 변수:**
- `resource_group_name`: 리소스 그룹 이름
- `virtual_network_name`: 가상 네트워크 이름
- `subnets`: 서브넷 설정 맵
- `tags`: 태그 맵

**서브넷 설정 옵션:**
- `name`: 서브넷 이름 (선택, 지정하지 않으면 자동 생성)
- `address_prefixes`: 주소 접두사 리스트
- `network_security_group_id`: NSG ID (선택)
- `route_table_id`: 라우트 테이블 ID (선택)
- `service_endpoints`: 서비스 엔드포인트 리스트 (선택)
- `service_endpoint_policy_ids`: 서비스 엔드포인트 정책 ID 리스트 (선택)
- `delegation`: 서브넷 위임 설정 (선택)

**출력:**
- `subnet_ids`: 서브넷 키에서 서브넷 ID로의 맵
- `subnet_names`: 서브넷 키에서 서브넷 이름으로의 맵
- `subnets`: 서브넷 객체 맵

#### Application Gateway 모듈 (`modules/networking/agw/`)

Azure Application Gateway를 관리하는 모듈입니다.

**입력 변수:**
- `name`: Application Gateway 이름
- `resource_group_name`: 리소스 그룹 이름
- `location`: Azure 지역
- `subnet_id`: Application Gateway용 서브넷 ID
- `sku_name`, `sku_tier`, `capacity`: SKU 설정
- `public_ip_enabled`: Public IP 생성 여부
- `frontend_ports`: 프론트엔드 포트 리스트
- `backend_address_pools`: 백엔드 주소 풀 리스트
- `backend_http_settings`: 백엔드 HTTP 설정 리스트
- `http_listeners`: HTTP 리스너 리스트
- `request_routing_rules`: 요청 라우팅 규칙 리스트
- `container_app_fqdns`: Container Apps FQDN 맵 (자동 연결용)
- `tags`: 태그 맵

**출력:**
- `id`: Application Gateway ID
- `name`: Application Gateway 이름
- `public_ip_address`: Public IP 주소
- `public_ip_id`: Public IP ID
#### Private Endpoint 모듈 (`modules/networking/pe/`)

Private Endpoints와 Private DNS Zones를 통합하여 관리하는 모듈입니다.

**입력 변수:**
- `resource_group_name`: 리소스 그룹 이름
- `location`: Azure 지역
- `vnet_id`: Virtual Network ID
- `private_dns_zones`: Private DNS Zone 설정 맵
- `private_endpoints`: Private Endpoint 설정 맵
- `tags`: 태그 맵

**출력:**
- `private_dns_zone_ids`: Private DNS Zone ID 맵
- `private_endpoint_ids`: Private Endpoint ID 맵

### Compute 모듈

#### Container Apps 모듈 (`modules/compute/container-apps/`)

Azure Container Apps, Virtual Machines, 그리고 Log Analytics Workspace를 관리하는 모듈입니다.

**입력 변수:**
- `resource_group_name`: 리소스 그룹 이름
- `location`: Azure 지역
- `container_app_environment_name`: Container App Environment 이름
- `infrastructure_subnet_id`: Container Apps Environment용 서브넷 ID (선택)
- `log_analytics_workspace_id`: 기존 Log Analytics Workspace ID (선택, 없으면 생성)
- `log_analytics_workspace_name`: Log Analytics Workspace 이름 (선택)
- `log_analytics_workspace_suffix`: Log Analytics Workspace 이름 접미사
- `log_analytics_workspace_sku`: Log Analytics Workspace SKU
- `log_analytics_retention_days`: Log Analytics 보존 기간 (일)
- `container_apps`: Container App 설정 맵
- `virtual_machines`: Virtual Machine 설정 맵 (선택)
- `key_vault_id`: Key Vault ID (Container Apps에서 시크릿 사용 시)
- `key_vault_secrets`: Key Vault Secret ID 맵
- `tags`: 태그 맵

**Container App 설정 옵션:**
- `name`: Container App 이름 (선택, 지정하지 않으면 네이밍 규칙 자동 적용)
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

**Virtual Machine 설정 옵션:**
- `name`: Virtual Machine 이름
- `size`: VM 크기
- `subnet_id`: 서브넷 키 이름
- `os_type`: OS 타입 (Linux 또는 Windows)
- `admin_username`: 관리자 사용자명
- `admin_password`: 관리자 비밀번호 (Windows 필수)
- `admin_ssh_key`: SSH 공개키 (Linux 필수)
- `source_image_reference`: 소스 이미지 참조
- 기타 네트워크 및 디스크 설정

**출력:**
- `log_analytics_workspace_id`: Log Analytics Workspace ID
- `container_app_environment_id`: Container App Environment ID
- `container_app_environment_name`: Container App Environment 이름
- `container_app_ids`: Container App ID 맵
- `container_app_fqdns`: Container App FQDN 맵
- `container_apps`: Container App 객체 맵
- `virtual_machine_ids`: Virtual Machine ID 맵

### Data 모듈

데이터 저장소 서비스들을 관리하는 모듈들입니다.

**지원 서비스:**
- Container Registry (ACR) - `modules/data/acr/`
- Key Vault - `modules/data/keyvault/`
- Cosmos DB - `modules/data/cosmos/`
- PostgreSQL - `modules/data/postgres/`

### Services 모듈

AI 서비스 모듈들입니다. 각 서비스는 독립적으로 사용할 수 있습니다:

**데이터 저장소 서비스:**
- `modules/data/acr/`: Container Registry
- `modules/data/keyvault/`: Key Vault
- `modules/data/cosmos/`: Cosmos DB
- `modules/data/postgres/`: PostgreSQL

**AI 서비스:**
- `modules/services/foundry/`: AI Foundry
- `modules/services/openai/`: OpenAI

#### AI Foundry 모듈 (`modules/services/foundry/`)

Azure AI Foundry Hub와 Project를 관리하고, Project 레벨에 Cognitive Services Account를 생성하여 모델을 배포합니다.

**구조:**
```
Hub (azurerm_ai_foundry)
 └─ Project-A (azurerm_ai_foundry_project)
      └─ AOAI Account (azurerm_cognitive_account)
           ├─ GPT-4.1 (azurerm_cognitive_deployment)
           └─ GPT-4.1-mini (azurerm_cognitive_deployment)
```

**주요 특징:**
- Hub 레벨에는 Cognitive Account를 생성하지 않음
- Project 레벨에만 Cognitive Services Account 생성
- 하나의 Account에 여러 모델 배포 가능
- Storage Account 자동 생성 또는 기존 Storage Account 사용 가능

**입력 변수:**
- `name`: Foundry Hub 이름
- `resource_group_name`: 리소스 그룹 이름
- `location`: Azure 지역
- `storage_account_id`: 기존 Storage Account ID (선택, null이면 자동 생성)
- `storage_account_name`: Storage Account 이름 (선택)
- `key_vault_id`: Key Vault ID (선택, 권장)
- `create_project`: Project 생성 여부 (기본값: false)
- `project_name`: Project 이름 (선택, 지정하지 않으면 `{name}-project`)
- `deployments`: Hub 레벨 배포 설정 (현재 사용 안 함, 빈 객체)
- `project_deployments`: Project 레벨 배포 설정 (필수, 모델 배포)
- `cognitive_account_sku_name`: Cognitive Account SKU (기본값: "S0")
- `public_network_access_enabled`: Public network access 활성화 여부 (기본값: false)
- `identity_type`: Managed Identity 타입 (기본값: "SystemAssigned")

**배포 설정 예시:**
```hcl
foundry_config = {
  storage_account_id = null  # null이면 자동 생성
  create_project = true
  project_name = null  # 자동 생성: {foundry_name}-project
  
  # Hub 레벨 배포 (사용 안 함)
  deployments = {}
  
  # Project 레벨 배포
  project_deployments = {
    "gpt-4.1" = {
      name = "gpt-4.1"
      model_name = "gpt-4.1"
      model_format = "OpenAI"
      version_upgrade_option = "OnceNewDefaultVersionAvailable"
      scale = {
        name = "GlobalStandard"
        capacity = null
      }
    }
    "gpt-4.1-mini" = {
      name = "gpt-4.1-mini"
      model_name = "gpt-4.1-mini"
      model_format = "OpenAI"
      version_upgrade_option = "OnceNewDefaultVersionAvailable"
      scale = {
        name = "GlobalStandard"
        capacity = null
      }
    }
  }
  
  identity_type = "SystemAssigned"
}
```

**출력:**
- `foundry_id`: Foundry Hub ID
- `foundry_name`: Foundry Hub 이름
- `foundry_endpoint`: Foundry Hub discovery URL
- `project_id`: Project ID (생성된 경우)
- `project_name`: Project 이름 (생성된 경우)
- `cognitive_account_id`: Project Cognitive Account ID
- `cognitive_account_name`: Project Cognitive Account 이름
- `project_deployment_ids`: Project 배포 ID 맵
- `project_deployment_names`: Project 배포 이름 맵
- `storage_account_id`: Storage Account ID

**주의사항:**
- Azure OpenAI Service 접근 권한이 구독에 활성화되어 있어야 함
- 모델 배포를 위한 quota가 필요함 (Azure Portal에서 확인 및 요청)
- `gpt-4.1` 및 `gpt-4.1-mini` 모델은 구독에 quota가 할당되어 있어야 함
- 자세한 내용은 [AZURE_OPENAI_SETUP.md](AZURE_OPENAI_SETUP.md) 참조

#### OpenAI 모듈 (`modules/services/openai/`)

독립적인 Azure OpenAI Cognitive Services Account를 생성하고 모델을 배포합니다.

**입력 변수:**
- `name`: OpenAI Account 이름
- `resource_group_name`: 리소스 그룹 이름
- `location`: Azure 지역
- `sku_name`: SKU 이름 (기본값: "S0")
- `deployments`: 모델 배포 설정 맵
- `public_network_access_enabled`: Public network access 활성화 여부
- `identity_type`: Managed Identity 타입
- `key_vault_id`: Key Vault ID (선택)

**출력:**
- `cognitive_account_id`: Cognitive Account ID
- `cognitive_account_name`: Cognitive Account 이름
- `deployment_ids`: 배포 ID 맵
- `deployment_names`: 배포 이름 맵

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
| Application Gateway | `{프로젝트}-{환경}-{용도/기능}-agw` | `tmp-dev-agent-agw` |
| Container Apps Environment | `{프로젝트}-{환경}-{용도/기능}-cae-{순번}` | `tmp-dev-agent-cae-001` |
| Container Apps | `{프로젝트}-{환경}-{용도/기능}-aca-{순번}` | `tmp-dev-search-aca-001` |
| Container Registry | `{프로젝트}{환경}{용도/기능}acr{순번}` | `tmpdevagentacr001` (ACR은 하이픈 불가) |
| Key Vault | `{프로젝트}-{환경}-{용도/기능}-kv-{순번}` | `tmp-dev-agent-kv-001` |
| Cosmos DB | `{프로젝트}-{환경}-{용도/기능}-cosmos-{순번}` | `tmp-dev-agent-cosmos-001` |
| PostgreSQL | `{프로젝트}-{환경}-{용도/기능}-pgsql-{순번}` | `tmp-dev-agent-pgsql-001` |
| AI Foundry Hub | `{프로젝트}-{환경}-{용도/기능}-aif` | `tmp-dev-agent-aif` |
| AI Foundry Project | `{foundry_name}-project` | `tmp-dev-agent-aif-project` |
| AI Foundry Cognitive Account | `{project_name}-cog` | `tmp-dev-agent-aif-project-cog` |
| OpenAI | `{프로젝트}-{환경}-{용도/기능}-aoai-{순번}` | `tmp-dev-agent-aoai-001` |

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

## 주요 기능

- **모듈화된 구조**: 재사용 가능한 모듈로 구성되어 유지보수가 용이합니다
- **자동 네이밍 규칙**: 표준화된 네이밍 규칙을 지원하여 일관성 있는 리소스 이름 생성
- **환경별 분리**: `env/` 디렉토리를 통한 환경별 독립 배포 지원
- **통합 서비스 관리**: PaaS 서비스들을 통합 모듈로 관리
- **Private Endpoint 지원**: 보안을 위한 Private Endpoint 및 Private DNS Zone 자동 구성
- **Application Gateway 통합**: Container Apps와 자동 연결되는 Application Gateway 지원
- **태그 관리**: 공통 태그 자동 적용 및 병합 기능

## 요구사항

- Terraform >= 1.0
- Azure Provider ~> 4.40
- Azure CLI 또는 Service Principal 인증 설정 필요

## 추가 문서

프로젝트에는 다음과 같은 추가 문서가 포함되어 있습니다:

- [env/README.md](env/README.md): 환경별 배포 가이드
- [MODULE_STRUCTURE.md](MODULE_STRUCTURE.md): 모듈 구조 상세 설명
- [RESOURCES.md](RESOURCES.md): 배포 리소스 상세 정보
- [DEPLOYMENT.md](DEPLOYMENT.md): 배포 가이드
- [COST_ESTIMATION.md](COST_ESTIMATION.md): 비용 예상 정보
- [KEYVAULT_SECRETS.md](KEYVAULT_SECRETS.md): Key Vault 시크릿 관리 가이드

## 참고 자료

- [Terraform Azure Provider 공식 문서](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Resource Group 리소스](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group)
- [Azure Virtual Network 리소스](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network)
- [Azure Subnet 리소스](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet)
- [Azure Container Apps 리소스](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app)
- [Azure Application Gateway 리소스](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway)
- [Azure Private Endpoint 리소스](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint)
