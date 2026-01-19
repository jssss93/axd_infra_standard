# 배포 순서 가이드

## Terraform 자동 배포 순서

Terraform은 리소스 간 의존성을 자동으로 감지하여 올바른 순서로 배포합니다. 다음은 실제 배포 순서입니다:

### 1단계: Resource Group 생성
```
module.rg (Resource Group)
├─ azurerm_resource_group.this
```
- **의존성**: 없음 (최상위 리소스)
- **생성 시간**: ~5초
- **생성 리소스**: `tmp-dev-agent-rg`

### 2단계: Network 인프라 생성
```
module.network (Network)
├─ azurerm_virtual_network.this
├─ azurerm_subnet.this["appgw"]
├─ azurerm_subnet.this["cae"]
├─ azurerm_subnet.this["vm"]
├─ azurerm_subnet.this["pe"]
├─ azurerm_subnet_network_security_group_association.this (if NSG exists)
└─ azurerm_subnet_route_table_association.this (if Route Table exists)
```
- **의존성**: `module.rg` (Resource Group)
- **생성 시간**: ~30초
- **생성 리소스**:
  - VNet: `tmp-dev-agent-vnet`
  - Subnets: `tmp-dev-agent-appgw-sbn`, `tmp-dev-agent-cae-sbn`, `tmp-dev-agent-vm-sbn`, `tmp-dev-agent-pe-sbn`

### 3단계: Compute 리소스 생성
```
module.compute (Container Apps)
├─ azurerm_log_analytics_workspace.this (if not provided)
├─ azurerm_container_app_environment.this
└─ azurerm_container_app.this["webapp"]
```
- **의존성**: 
  - `module.rg` (Resource Group)
  - `module.network` (Subnet ID for Container Apps Environment)
- **생성 시간**: ~5-10분 (Container Apps Environment 생성에 시간 소요)
- **생성 리소스**:
  - Log Analytics Workspace: `tmp-dev-agent-cae-001-laws` (if auto-created)
  - Container App Environment: `tmp-dev-agent-cae-001`
  - Container Apps: `webapp` (FQDN 자동 생성)

### 4단계: Application Gateway 생성
```
module.appgw (Application Gateway)
├─ azurerm_public_ip.this (if public_ip_enabled = true)
└─ azurerm_application_gateway.this
```
- **의존성**: 
  - `module.rg` (Resource Group)
  - `module.network` (Subnet ID for Application Gateway)
  - `module.compute` (Container Apps FQDN - 명시적 `depends_on`)
- **생성 시간**: ~10-15분 (Application Gateway 생성에 시간 소요)
- **생성 리소스**:
  - Public IP: `tmp-dev-agent-appgw-pip` (if enabled)
  - Application Gateway: `tmp-dev-agent-appgw`
  - Backend Pool에 Container Apps FQDN 자동 연결

## 실제 배포 명령어

### 개발 환경 배포

```bash
# 1. 환경 디렉토리로 이동
cd env/dev

# 2. Terraform 초기화 (최초 1회 또는 모듈 변경 시)
terraform init

# 3. Backend 설정 (선택사항, 원격 상태 저장소 사용 시)
# backend.tf 파일 생성 또는 terraform init -backend-config=backend.tfvars

# 4. 배포 계획 확인
terraform plan

# 5. 배포 실행
terraform apply

# 6. 배포 확인
terraform output
```

### 배포 순서 확인

```bash
# Terraform이 감지한 의존성 그래프 확인
terraform graph | dot -Tsvg > graph.svg

# 또는 텍스트 형식으로 확인
terraform graph
```

## 배포 흐름도

```
┌─────────────────┐
│  Resource Group │ ← 1단계: 최초 생성
└────────┬────────┘
         │
         ├─────────────────┐
         │                 │
┌────────▼────────┐  ┌────▼──────────────┐
│  Network (VNet) │  │  Log Analytics    │
│  + Subnets      │  │  Workspace        │
└────────┬────────┘  └────┬──────────────┘
         │                 │
         │                 │
┌────────▼─────────────────▼──────────────┐
│  Container App Environment              │
│  + Container Apps                       │
│  (FQDN 생성됨)                          │
└────────┬────────────────────────────────┘
         │
         │ (FQDN 전달)
         │
┌────────▼────────────────────────────────┐
│  Application Gateway                    │
│  + Public IP                            │
│  (Backend Pool에 Container Apps 연결)   │
└─────────────────────────────────────────┘
```

## 주의사항

### 1. Container Apps FQDN 대기
- Application Gateway는 Container Apps의 FQDN이 생성된 후에 배포됩니다
- `depends_on = [module.compute]`로 명시적 의존성 설정됨

### 2. 네트워크 준비 시간
- VNet과 Subnet 생성 후 Container Apps Environment가 배포됩니다
- Subnet이 완전히 준비될 때까지 대기합니다

### 3. Application Gateway 배포 시간
- Application Gateway는 가장 오래 걸리는 리소스입니다 (10-15분)
- Backend Pool에 Container Apps FQDN이 자동으로 연결됩니다

## 단계별 배포 (선택사항)

필요한 경우 단계별로 배포할 수 있습니다:

```bash
# 1단계: Resource Group만 생성
terraform apply -target=module.rg

# 2단계: Network만 생성
terraform apply -target=module.network

# 3단계: Compute만 생성
terraform apply -target=module.compute

# 4단계: Application Gateway만 생성
terraform apply -target=module.appgw

# 전체 배포
terraform apply
```

## 배포 확인

배포 완료 후 다음 명령어로 확인:

```bash
# 모든 리소스 상태 확인
terraform show

# 출력 값 확인 (FQDN, IP 등)
terraform output

# 특정 리소스 확인
terraform state list
terraform state show module.compute.azurerm_container_app.this["webapp"]
terraform state show module.appgw[0].azurerm_application_gateway.this
```

## 롤백 (삭제)

```bash
# 전체 리소스 삭제
terraform destroy

# 특정 리소스만 삭제
terraform destroy -target=module.appgw
terraform destroy -target=module.compute
```

## 예상 배포 시간

| 단계 | 리소스 | 예상 시간 |
|------|--------|----------|
| 1단계 | Resource Group | ~5초 |
| 2단계 | Network (VNet + Subnets) | ~30초 |
| 3단계 | Container Apps Environment + Apps | ~5-10분 |
| 4단계 | Application Gateway | ~10-15분 |
| **전체** | **모든 리소스** | **~15-25분** |

## 문제 해결

### Application Gateway 배포 실패 시
- Container Apps FQDN이 생성되었는지 확인: `terraform output container_app_fqdns`
- Backend Pool 설정 확인: Application Gateway 모듈의 backend_address_pools 확인

### Container Apps 배포 실패 시
- Subnet이 올바르게 생성되었는지 확인: `terraform output subnet_ids`
- Container Apps Environment가 준비되었는지 확인
