# Terraform Plan 상세 분석

## 📊 플랜 요약

**Plan: 35 to add, 0 to change, 35 to destroy**

### ⚠️ 중요 발견사항

현재 `terraform.tfvars` 파일에서 `environment = "prd"`로 설정되어 있어, 기존 dev 환경의 모든 리소스가 삭제되고 prd 환경 리소스로 교체됩니다.

## 🔄 교체되는 리소스 분석

### 1. Resource Group 교체 (모든 리소스 교체의 원인)

**기존:** `tmp-dev-agent-rg`  
**새로 생성:** `tmp-prd-agent-rg`

**영향:**
- Resource Group 이름 변경으로 인해 모든 리소스가 교체됨
- Resource Group은 다른 리소스의 부모이므로, 모든 자식 리소스도 함께 교체됨

### 2. 교체되는 리소스 목록 (총 35개)

#### Foundation (1개)
- ✅ `azurerm_resource_group.this` - 이름 변경 (`tmp-dev-agent-rg` → `tmp-prd-agent-rg`)

#### Networking (10개)
- ✅ `azurerm_virtual_network.this` - Resource Group 변경으로 교체
- ✅ `azurerm_subnet.this["agw"]` - Resource Group 변경으로 교체
- ✅ `azurerm_subnet.this["cae"]` - Resource Group 변경으로 교체
- ✅ `azurerm_subnet.this["vm"]` - Resource Group 변경으로 교체
- ✅ `azurerm_subnet.this["pe"]` - Resource Group 변경으로 교체
- ✅ `azurerm_application_gateway.this` - Resource Group 변경으로 교체
- ✅ `azurerm_public_ip.agw[0]` - Resource Group 변경으로 교체
- ✅ `azurerm_private_dns_zone.this[*]` (4개) - Resource Group 변경으로 교체
- ✅ `azurerm_private_dns_zone_virtual_network_link.this[*]` (4개) - Resource Group 변경으로 교체
- ✅ `azurerm_private_endpoint.this[*]` (4개) - Resource Group 변경으로 교체

#### Data Services (4개)
- ✅ `azurerm_container_registry.this` - Resource Group 변경으로 교체
- ✅ `azurerm_cosmosdb_account.this` - Resource Group 변경으로 교체
- ✅ `azurerm_key_vault.this` - Resource Group 변경으로 교체
- ✅ `azurerm_postgresql_flexible_server.this` - Resource Group 변경으로 교체

#### AI Services (5개)
- ✅ `azurerm_ai_foundry.foundry` - Resource Group 변경으로 교체
- ✅ `azurerm_ai_foundry_project.project` - Resource Group 변경으로 교체
- ✅ `azurerm_storage_account.foundry[0]` - Resource Group 변경으로 교체
- ✅ `azurerm_cognitive_account.project[0]` - Resource Group 변경으로 교체
- ✅ `azurerm_cognitive_account.openai` - Resource Group 변경으로 교체
- ✅ `azurerm_cognitive_deployment.project_deployments[*]` (2개) - Resource Group 변경으로 교체

#### Compute (5개)
- ✅ `azurerm_container_app_environment.this` - Resource Group 변경으로 교체
- ✅ `azurerm_log_analytics_workspace.this[0]` - Resource Group 변경으로 교체
- ✅ `azurerm_container_app.this["webapp"]` - 이름 변경 (`tmp-dev-agent-aca-webapp-001` → `tmp-prd-agent-aca-webapp-001`)
- ✅ `azurerm_container_app.this["webapp-002"]` - 이름 변경 (`tmp-dev-agent-aca-webapp-002` → `tmp-prd-agent-aca-webapp-002`)

## 🔍 교체 이유 분석

### 주요 교체 원인

1. **Resource Group 이름 변경** (35개 리소스 모두)
   - `tmp-dev-agent-rg` → `tmp-prd-agent-rg`
   - Azure에서 Resource Group은 변경 불가능하므로 교체 필요

2. **Container App 이름 변경** (2개)
   - `tmp-dev-agent-aca-webapp-001` → `tmp-prd-agent-aca-webapp-001`
   - `tmp-dev-agent-aca-webapp-002` → `tmp-prd-agent-aca-webapp-002`
   - Container App 이름은 변경 불가능하므로 교체 필요

3. **Environment 태그 변경** (모든 리소스)
   - `Environment = "dev"` → `Environment = "prd"`
   - 태그 변경만으로는 교체되지 않지만, 이름 변경과 함께 발생

## ⚠️ 주의사항

### 1. 데이터 손실 위험

**영향받는 리소스:**
- **Cosmos DB**: 데이터베이스 내용이 삭제됨
- **PostgreSQL**: 데이터베이스 내용이 삭제됨
- **Key Vault**: 저장된 시크릿이 삭제됨
- **Container Registry**: 저장된 이미지가 삭제됨
- **Storage Account**: 저장된 파일이 삭제됨

### 2. 다운타임

모든 리소스가 삭제 후 재생성되므로:
- **Application Gateway**: 다운타임 발생
- **Container Apps**: 다운타임 발생
- **Private Endpoints**: 연결 중단 발생

### 3. 네트워크 변경

- **Virtual Network**: 새로운 VNet 생성으로 기존 연결 설정 초기화
- **Subnets**: 새로운 서브넷 생성
- **Private Endpoints**: 새로운 Private Endpoint 생성 (DNS 설정 재구성 필요)

## 💡 해결 방안

### 옵션 1: Dev 환경 유지 (권장)

`terraform.tfvars` 파일을 수정하여 dev 환경을 유지:

```hcl
environment = "dev"  # "prd" → "dev"로 변경
```

### 옵션 2: Prd 환경으로 마이그레이션 (주의 필요)

Prd 환경으로 전환하려면:

1. **데이터 백업 필수**
   - Cosmos DB 데이터 백업
   - PostgreSQL 데이터 백업
   - Key Vault 시크릿 백업
   - Container Registry 이미지 백업

2. **단계적 마이그레이션**
   - Blue-Green 배포 전략 고려
   - 데이터 마이그레이션 계획 수립

3. **다운타임 계획**
   - 유지보수 시간대에 실행
   - 사용자에게 공지

## 📈 리소스별 상세 변경사항

### Resource Group
```diff
- name: tmp-dev-agent-rg
+ name: tmp-prd-agent-rg
- tags.Environment: dev
+ tags.Environment: prd
```

### Container Apps
```diff
- name: tmp-dev-agent-aca-webapp-001
+ name: tmp-prd-agent-aca-webapp-001
- resource_group_name: tmp-dev-agent-rg
+ resource_group_name: tmp-prd-agent-rg
```

### 모든 리소스 공통
```diff
- resource_group_name: tmp-dev-agent-rg
+ resource_group_name: tmp-prd-agent-rg
- tags.Environment: dev
+ tags.Environment: prd
```

## 🎯 권장 조치사항

1. ✅ **즉시 조치**: `terraform.tfvars`에서 `environment = "dev"`로 변경
2. ✅ **플랜 재실행**: 변경 후 플랜 재실행하여 변경사항 확인
3. ⚠️ **주의**: 이 플랜을 적용하면 dev 환경이 완전히 삭제됩니다

## 📝 다음 단계

1. `terraform.tfvars` 파일 확인 및 수정
2. 플랜 재실행: `terraform plan`
3. 변경사항 검토
4. 필요시 apply 실행
