# Terraform 배포 순서 및 의존도 상관관계

## 전체 배포 순서 다이어그램

```
┌─────────────────────────────────────────────────────────────────┐
│ Phase 0: Naming Module (의존성 없음)                           │
│ - 모든 리소스 이름 생성                                          │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│ Phase 1: Foundation                                             │
│ ┌─────────────┐                                                 │
│ │ Resource    │  ← 모든 리소스의 기본 컨테이너                  │
│ │ Group       │                                                 │
│ └─────────────┘                                                 │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│ Phase 2: Networking (순차적 의존성)                             │
│ ┌─────────────┐                                                 │
│ │ Virtual     │  ← Resource Group 의존                           │
│ │ Network     │                                                 │
│ └──────┬──────┘                                                 │
│        │                                                        │
│        ▼                                                        │
│ ┌─────────────┐                                                 │
│ │ Subnets     │  ← VNet 의존                                    │
│ └──────┬──────┘                                                 │
│        │                                                        │
│        ├──────────────────┬──────────────────┐                │
│        ▼                  ▼                  ▼                │
│ ┌─────────────┐  ┌─────────────┐  ┌─────────────┐            │
│ │ Application │  │ Private     │  │ Private     │            │
│ │ Gateway     │  │ DNS Zones   │  │ Endpoints   │            │
│ │             │  │             │  │             │            │
│ │ (Subnet     │  │ (VNet Link) │  │ (Subnet     │            │
│ │  의존)      │  │             │  │  의존)      │            │
│ └─────────────┘  └─────────────┘  └─────────────┘            │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│ Phase 3: Data Services (병렬 생성 가능)                          │
│ ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│ │ Key Vault  │  │ Container   │  │ Cosmos DB   │             │
│ │            │  │ Registry    │  │             │             │
│ │ (먼저 생성 │  │ (ACR)       │  │             │             │
│ │  권장)     │  │             │  │             │             │
│ └──────┬─────┘  └─────────────┘  └─────────────┘             │
│        │                                                        │
│        ▼                                                        │
│ ┌─────────────┐                                                 │
│ │ PostgreSQL  │  ← Key Vault와 독립적                          │
│ │             │                                                 │
│ └─────────────┘                                                 │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│ Phase 4: Services (Key Vault 의존)                              │
│ ┌─────────────┐  ┌─────────────┐                               │
│ │ AI Foundry  │  │ OpenAI      │                               │
│ │            │  │             │                               │
│ │ (Key Vault │  │ (Key Vault  │                               │
│ │  ID 필요)  │  │  ID 필요)   │                               │
│ └─────────────┘  └─────────────┘                               │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│ Phase 5: Afterjob (모든 서비스 생성 후 실행)                    │
│ ┌─────────────┐                                                 │
│ │ Key Vault  │  ← Data + Services 모듈 완료 후 실행            │
│ │ Secrets    │                                                 │
│ │            │                                                 │
│ │ - ACR credentials                                            │
│ │ - Cosmos DB keys                                             │
│ │ - PostgreSQL credentials                                     │
│ │ - Foundry endpoint                                           │
│ │ - OpenAI keys                                                │
│ └─────────────┘                                                 │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│ Phase 6: Compute (여러 리소스 의존)                             │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ Container Apps                                               │ │
│ │ ┌──────────────┐  ┌──────────────┐                        │ │
│ │ │ Log         │  │ Container    │                        │ │
│ │ │ Analytics   │  │ App          │                        │ │
│ │ │ Workspace   │  │ Environment  │                        │ │
│ │ │             │  │              │                        │ │
│ │ │ (독립 생성) │  │ (Subnet +    │                        │ │
│ │ │             │  │  LAW 의존)   │                        │ │
│ │ └──────────────┘  └──────┬───────┘                        │ │
│ │                          │                                │ │
│ │                          ▼                                │ │
│ │                  ┌──────────────┐                        │ │
│ │                  │ Container    │                        │ │
│ │                  │ Apps         │                        │ │
│ │                  │              │                        │ │
│ │                  │ (Environment │                        │ │
│ │                  │  + Key Vault │                        │ │
│ │                  │  Secrets     │                        │ │
│ │                  │  의존)       │                        │ │
│ │                  └──────────────┘                        │ │
│ └─────────────────────────────────────────────────────────────┘ │
│                                                                 │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ Virtual Machines                                             │ │
│ │ ┌──────────────┐  ┌──────────────┐                        │ │
│ │ │ Public IP    │  │ Network      │                        │ │
│ │ │ (선택)       │  │ Interface    │                        │ │
│ │ └──────┬───────┘  │              │                        │ │
│ │        │          │ (Subnet     │                        │ │
│ │        │          │  의존)       │                        │ │
│ │        └──────┬───┴──────────────┘                        │ │
│ │               │                                            │ │
│ │               ▼                                            │ │
│ │         ┌──────────────┐                                   │ │
│ │         │ Virtual      │                                   │ │
│ │         │ Machine      │                                   │ │
│ │         │              │                                   │ │
│ │         │ (NIC 의존)   │                                   │ │
│ │         └──────────────┘                                   │ │
│ └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## 상세 의존도 관계

### 1. Naming Module
- **의존성**: 없음 (최우선 실행)
- **역할**: 모든 리소스 이름 생성

### 2. Resource Group (Phase 1)
- **의존성**: Naming Module
- **역할**: 모든 리소스의 기본 컨테이너
- **다음 단계**: 모든 모듈이 이 RG에 의존

### 3. Networking Module (Phase 2)

#### 3.1 Virtual Network
- **의존성**: Resource Group
- **생성 순서**: 1순위

#### 3.2 Subnets
- **의존성**: Virtual Network
- **생성 순서**: VNet 이후
- **특이사항**: 
  - `cae` subnet은 Container Apps Environment에 필요
  - `pe` subnet은 Private Endpoints에 필요
  - `agw` subnet은 Application Gateway에 필요

#### 3.3 Application Gateway
- **의존성**: 
  - Subnets (agw subnet)
  - Container Apps FQDNs (자동 연결 시)
- **생성 순서**: Subnets 이후, Container Apps FQDNs 필요 시 Compute 이후

#### 3.4 Private DNS Zones
- **의존성**: Resource Group
- **생성 순서**: VNet과 병렬 가능
- **리소스**:
  - `privatelink.vaultcore.azure.net` (Key Vault)
  - `privatelink.azurecr.io` (ACR)
  - `privatelink.documents.azure.com` (Cosmos DB)
  - `privatelink.postgres.database.azure.com` (PostgreSQL)

#### 3.5 Private DNS Zone Virtual Network Links
- **의존성**: 
  - Private DNS Zones
  - Virtual Network
- **생성 순서**: DNS Zones + VNet 이후

#### 3.6 Private Endpoints
- **의존성**: 
  - Subnets (pe subnet)
  - Private DNS Zones
  - 대상 리소스 (Key Vault, ACR, Cosmos DB, PostgreSQL)
- **생성 순서**: Data Module 리소스 생성 후
- **특이사항**: 각 Private Endpoint는 해당 서비스 리소스 ID 필요

### 4. Data Module (Phase 3)

#### 4.1 Key Vault
- **의존성**: Resource Group
- **생성 순서**: 최우선 (다른 서비스가 참조)
- **다음 단계**: Services Module이 Key Vault ID 필요

#### 4.2 Container Registry (ACR)
- **의존성**: Resource Group
- **생성 순서**: Key Vault와 병렬 가능
- **다음 단계**: Afterjob에서 credentials 저장

#### 4.3 Cosmos DB
- **의존성**: Resource Group
- **생성 순서**: Key Vault와 병렬 가능
- **다음 단계**: Afterjob에서 keys 저장

#### 4.4 PostgreSQL
- **의존성**: Resource Group
- **생성 순서**: Key Vault와 병렬 가능
- **다음 단계**: Afterjob에서 credentials 저장

### 5. Services Module (Phase 4)

#### 5.1 AI Foundry
- **의존성**: 
  - Resource Group
  - Key Vault ID
- **생성 순서**: Data Module 완료 후
- **내부 순서**:
  1. Storage Account (선택)
  2. AI Foundry Workspace
  3. AI Foundry Project (선택)
  4. Cognitive Account (Project용)
  5. Cognitive Deployments

#### 5.2 OpenAI
- **의존성**: 
  - Resource Group
  - Key Vault ID
- **생성 순서**: Data Module 완료 후
- **내부 순서**:
  1. Cognitive Account
  2. Cognitive Deployments

### 6. Afterjob Module (Phase 5)
- **의존성**: 
  - Data Module 완료
  - Services Module 완료
- **역할**: Key Vault에 모든 서비스의 secrets 저장
- **생성 순서**: 모든 서비스 생성 완료 후
- **Secrets**:
  - ACR: login_server, admin_username, admin_password
  - Cosmos DB: endpoint, primary_key, secondary_key
  - PostgreSQL: fqdn, admin_login, password
  - Foundry: endpoint
  - OpenAI: endpoint, primary_key, secondary_key

### 7. Compute Module (Phase 6)

#### 7.1 Log Analytics Workspace
- **의존성**: Resource Group
- **생성 순서**: Container App Environment 이전
- **역할**: Container Apps 로깅

#### 7.2 Container App Environment
- **의존성**: 
  - Resource Group
  - Subnets (cae subnet)
  - Log Analytics Workspace
- **생성 순서**: LAW + Subnets 이후

#### 7.3 Container Apps
- **의존성**: 
  - Container App Environment
  - Key Vault Secrets (Afterjob 완료 후)
- **생성 순서**: Environment + Afterjob 완료 후
- **특이사항**: 
  - Key Vault secrets 참조 시 Afterjob 완료 필수
  - Application Gateway 자동 연결 시 FQDN 필요

#### 7.4 Virtual Machines
- **의존성**: 
  - Resource Group
  - Subnets
  - Public IP (선택)
- **생성 순서**: Subnets 이후
- **내부 순서**:
  1. Public IP (선택)
  2. Network Interface (Subnet + Public IP)
  3. Virtual Machine (NIC)

## 순환 의존성 해결

### Application Gateway ↔ Container Apps
- **문제**: AppGW는 Container Apps FQDNs 필요, Container Apps는 독립적
- **해결**: 
  - Container Apps 먼저 생성
  - AppGW는 `container_app_fqdns` 변수로 FQDNs 받음
  - `auto_connect_container_apps=true` 시 자동 연결

### Private Endpoints ↔ Data Services
- **문제**: PE는 서비스 리소스 ID 필요, 서비스는 독립적
- **해결**: 
  - Data Services 먼저 생성
  - PE는 서비스 ID를 참조하여 생성

## 배포 타임라인 예상

```
시간축 →
[0s]     Naming Module
[1s]     Resource Group
[2s]     Virtual Network
[3s]     Subnets
[4s]     ┌─ Key Vault ──────────────┐
         ├─ ACR ───────────────────┤
         ├─ Cosmos DB ─────────────┤  (병렬)
         └─ PostgreSQL ────────────┘
[30s]    Private DNS Zones
[31s]    Private DNS Zone Links
[32s]    ┌─ Foundry ───────────────┐
         └─ OpenAI ────────────────┘  (병렬, Key Vault 의존)
[60s]    Private Endpoints (Data Services)
[90s]    Afterjob (Key Vault Secrets)
[91s]    Log Analytics Workspace
[92s]    Container App Environment
[93s]    Container Apps
[94s]    Application Gateway (Container Apps FQDNs 사용)
[120s]   Virtual Machines
```

## 주의사항

1. **Key Vault는 최우선 생성**: 다른 서비스들이 Key Vault ID를 참조
2. **Afterjob는 마지막에 실행**: 모든 서비스 생성 완료 후 secrets 저장
3. **Container Apps는 Afterjob 이후**: Key Vault secrets 참조 시 필요
4. **Application Gateway는 Container Apps 이후**: FQDNs 필요 시
5. **Private Endpoints는 서비스 생성 후**: 각 서비스 리소스 ID 필요

## 모듈 간 명시적 의존성 (depends_on)

코드에서 명시적으로 정의된 의존성:

```hcl
# Services Module
depends_on = [module.data]

# Afterjob Module  
depends_on = [
  module.data,
  module.services
]

# Compute Module
depends_on = [module.data]
```

## 리소스 간 암시적 의존성

Terraform이 자동으로 감지하는 의존성:

- `module.networking.subnet_ids[...]` → Subnets 생성 후
- `module.data.key_vault_id` → Key Vault 생성 후
- `module.compute.container_app_fqdns` → Container Apps 생성 후
- `azurerm_container_app_environment.this.id` → Environment 생성 후
- `azurerm_log_analytics_workspace.this[0].id` → LAW 생성 후
