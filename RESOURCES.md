# 배포 리소스 상세 정보

이 문서는 `terraform plan` 결과를 기반으로 배포될 리소스들의 이름, SKU, 설정 정보를 정리한 것입니다.

## 환경 정보

- **Subscription ID**: `42f0cf0c-5a7a-4aca-9a9e-31b236b9defa`
- **Environment**: `dev`
- **Project Name**: `tmp`
- **Purpose**: `agent`
- **Location**: `koreacentral`

## 1. Resource Group

| 항목 | 값 |
|------|-----|
| **Resource Type** | `azurerm_resource_group` |
| **Name** | `tmp-dev-agent-rg` |
| **Location** | `koreacentral` |
| **SKU** | N/A (Resource Group은 SKU 없음) |
| **Tags** | `ManagedBy: Terraform`, `CreatedDate: YYYY-MM-DD`, `Owner: jongsu.choi@kt.com`, `Environment: dev`, `Project: tmp`, `Team: platform`, `CostCenter: engineering` |

---

## 2. Network 리소스

### 2.1 Virtual Network

| 항목 | 값 |
|------|-----|
| **Resource Type** | `azurerm_virtual_network` |
| **Name** | `tmp-dev-agent-vnet` |
| **Resource Group** | `tmp-dev-agent-rg` |
| **Location** | `koreacentral` |
| **Address Space** | `10.0.30.0/24` |
| **DNS Servers** | `[]` (없음) |
| **SKU** | N/A |
| **Tags** | 공통 태그 적용 |

### 2.2 Subnets

#### Subnet: Application Gateway 용

| 항목 | 값 |
|------|-----|
| **Resource Type** | `azurerm_subnet` |
| **Name** | `tmp-dev-agent-agw-sbn` |
| **Virtual Network** | `tmp-dev-agent-vnet` |
| **Address Prefixes** | `10.0.30.0/27` |
| **Service Endpoints** | 없음 |
| **Delegation** | 없음 |
| **NSG Association** | 없음 |
| **Route Table Association** | 없음 |

#### Subnet: Container App Environment 용

| 항목 | 값 |
|------|-----|
| **Resource Type** | `azurerm_subnet` |
| **Name** | `tmp-dev-agent-cae-sbn` |
| **Virtual Network** | `tmp-dev-agent-vnet` |
| **Address Prefixes** | `10.0.30.32/27` |
| **Service Endpoints** | 없음 |
| **Delegation** | 없음 |
| **NSG Association** | 없음 |
| **Route Table Association** | 없음 |

#### Subnet: VM 용

| 항목 | 값 |
|------|-----|
| **Resource Type** | `azurerm_subnet` |
| **Name** | `tmp-dev-agent-vm-sbn` |
| **Virtual Network** | `tmp-dev-agent-vnet` |
| **Address Prefixes** | `10.0.30.64/27` |
| **Service Endpoints** | 없음 |
| **Delegation** | 없음 |
| **NSG Association** | 없음 |
| **Route Table Association** | 없음 |

#### Subnet: Private Endpoint 용

| 항목 | 값 |
|------|-----|
| **Resource Type** | `azurerm_subnet` |
| **Name** | `tmp-dev-agent-pe-sbn` |
| **Virtual Network** | `tmp-dev-agent-vnet` |
| **Address Prefixes** | `10.0.30.224/27` |
| **Service Endpoints** | 없음 |
| **Delegation** | 없음 |
| **NSG Association** | 없음 |
| **Route Table Association** | 없음 |

---

## 3. Compute 리소스

### 3.1 Log Analytics Workspace

| 항목 | 값 |
|------|-----|
| **Resource Type** | `azurerm_log_analytics_workspace` |
| **Name** | `tmp-dev-agent-cae-001-laws` |
| **Resource Group** | `tmp-dev-agent-rg` |
| **Location** | `koreacentral` |
| **SKU** | `PerGB2018` |
| **Retention Days** | `30` |
| **Tags** | 공통 태그 적용 |

### 3.2 Container App Environment

| 항목 | 값 |
|------|-----|
| **Resource Type** | `azurerm_container_app_environment` |
| **Name** | `tmp-dev-agent-cae-001` |
| **Resource Group** | `tmp-dev-agent-rg` |
| **Location** | `koreacentral` |
| **Log Analytics Workspace ID** | `tmp-dev-agent-cae-001-laws` (위에서 생성) |
| **Infrastructure Subnet ID** | `tmp-dev-agent-cae-sbn` |
| **SKU** | N/A (Consumption Plan) |
| **Tags** | 공통 태그 적용 |

### 3.3 Container Apps

#### Container App: webapp

| 항목 | 값 |
|------|-----|
| **Resource Type** | `azurerm_container_app` |
| **Name** | `webapp` |
| **Container App Environment** | `tmp-dev-agent-cae-001` |
| **Resource Group** | `tmp-dev-agent-rg` |
| **Revision Mode** | `Single` |
| **Image** | `mcr.microsoft.com/azuredocs/containerapps-helloworld:latest` |
| **CPU** | `0.25` |
| **Memory** | `0.5Gi` |
| **Min Replicas** | `0` |
| **Max Replicas** | `2` |
| **Environment Variables** | `ENVIRONMENT: dev` |
| **Secrets** | 없음 |
| **Ingress** | |
| - External Enabled | `true` |
| - Target Port | `80` |
| - Transport | `auto` |
| **FQDN** | 자동 생성됨 (예: `webapp.xxx.azurecontainerapps.io`) |
| **Tags** | 공통 태그 적용 |

---

## 4. Application Gateway 리소스

### 4.1 Public IP

| 항목 | 값 |
|------|-----|
| **Resource Type** | `azurerm_public_ip` |
| **Name** | `tmp-dev-agent-agw-pip` |
| **Resource Group** | `tmp-dev-agent-rg` |
| **Location** | `koreacentral` |
| **Allocation Method** | `Static` |
| **SKU** | `Standard` |
| **IP Version** | `IPv4` (기본값) |
| **Tags** | 공통 태그 적용 |

### 4.2 Application Gateway

| 항목 | 값 |
|------|-----|
| **Resource Type** | `azurerm_application_gateway` |
| **Name** | `tmp-dev-agent-agw` |
| **Resource Group** | `tmp-dev-agent-rg` |
| **Location** | `koreacentral` |
| **SKU** | |
| - Name | `Standard_v2` |
| - Tier | `Standard_v2` |
| - Capacity | `2` |
| **Gateway IP Configuration** | |
| - Name | `tmp-dev-agent-agw-ip-config` |
| - Subnet ID | `tmp-dev-agent-agw-sbn` |
| **Frontend Ports** | |
| - http | Port `80` |
| - https | Port `443` |
| **Frontend IP Configuration** | |
| - Name | `tmp-dev-agent-agw-feip-public` |
| - Type | `Public` |
| - Public IP ID | `tmp-dev-agent-agw-pip` |
| **Backend Address Pools** | |
| - Name | `backend-pool` |
| - FQDNs | `[webapp.xxx.azurecontainerapps.io]` (자동 연결) |
| - IP Addresses | `[]` |
| **Backend HTTP Settings** | |
| - Name | `http-settings` |
| - Cookie Based Affinity | `Disabled` |
| - Path | `/` |
| - Port | `80` |
| - Protocol | `Http` |
| - Request Timeout | `20` 초 |
| - Host Name | 자동 설정됨 (Container App FQDN) |
| - Pick Host Name From Backend Address | `true` (자동 설정) |
| **HTTP Listeners** | |
| - Name | `http-listener` |
| - Frontend IP Configuration | `tmp-dev-agent-agw-feip-public` |
| - Frontend Port | `http` (80) |
| - Protocol | `Http` |
| - Host Name | 없음 |
| - SSL Certificate | 없음 |
| **Request Routing Rules** | |
| - Name | `http-rule` |
| - Rule Type | `Basic` |
| - HTTP Listener | `http-listener` |
| - Backend Address Pool | `backend-pool` |
| - Backend HTTP Settings | `http-settings` |
| **SSL Certificates** | 없음 |
| **Probes** | 없음 |
| **Tags** | 공통 태그 적용 |

---

## 리소스 요약

### 총 배포 리소스 수

| 카테고리 | 리소스 수 | 리소스 타입 |
|---------|----------|------------|
| **Foundation** | 1 | Resource Group |
| **Network** | 5 | VNet (1) + Subnets (4) |
| **Compute** | 3 | Log Analytics (1) + Container App Environment (1) + Container Apps (1) |
| **Application Gateway** | 2 | Public IP (1) + Application Gateway (1) |
| **Total** | **11** | |

### 네이밍 규칙 적용 리소스

모든 리소스는 다음 네이밍 규칙을 따릅니다:
- **형식**: `{프로젝트}-{환경}-{용도/기능}-{자산관리(선택)}-{리소스명}-{순번(선택)}`
- **예시**: `tmp-dev-agent-rg`, `tmp-dev-agent-vnet`, `tmp-dev-agent-agw`

### SKU 요약

| 리소스 | SKU |
|--------|-----|
| Log Analytics Workspace | `PerGB2018` |
| Public IP | `Standard` |
| Application Gateway | `Standard_v2` (Capacity: 2) |
| Container App Environment | Consumption Plan (SKU 없음) |

### 네트워크 주소 요약

| 리소스 | CIDR |
|--------|-----|
| Virtual Network | `10.0.30.0/24` |
| Subnet (agw) | `10.0.30.0/27` |
| Subnet (cae) | `10.0.30.32/27` |
| Subnet (vm) | `10.0.30.64/27` |
| Subnet (pe) | `10.0.30.224/27` |

### 태그 정보

모든 리소스에 다음 태그가 자동 적용됩니다:

| Key | Value |
|-----|-------|
| `ManagedBy` | `Terraform` |
| `CreatedDate` | `YYYY-MM-DD` (배포 날짜) |
| `Owner` | `jongsu.choi@kt.com` |
| `Environment` | `dev` |
| `Project` | `tmp` |
| `Team` | `platform` |
| `CostCenter` | `engineering` |

---

## 배포 후 확인 사항

### 1. Container Apps FQDN 확인

```bash
terraform output container_app_fqdns
```

예상 출력:
```
{
  "webapp" = "webapp.xxx.azurecontainerapps.io"
}
```

### 2. Application Gateway Public IP 확인

```bash
terraform output application_gateway_public_ip_address
```

### 3. Application Gateway FQDN 확인

```bash
terraform output application_gateway_fqdn
```

### 4. Backend Pool 연결 확인

Application Gateway의 Backend Pool에 Container Apps FQDN이 자동으로 연결되어 있는지 확인:
- Azure Portal → Application Gateway → Backend pools → `backend-pool`
- FQDNs에 Container App의 FQDN이 표시되어야 함

---

## 비용 예상

| 리소스 | SKU/Tier | 예상 월 비용 (대략) |
|--------|----------|-------------------|
| Resource Group | N/A | 무료 |
| Virtual Network | N/A | 무료 |
| Subnets | N/A | 무료 |
| Log Analytics Workspace | PerGB2018 | 사용량 기반 (~$2.30/GB) |
| Container App Environment | Consumption | 사용량 기반 (vCPU/GB 시간) |
| Container Apps | Consumption | 사용량 기반 (vCPU/GB 시간) |
| Public IP | Standard | ~$3.65/월 |
| Application Gateway | Standard_v2 (2 instances) | ~$150-200/월 |

**참고**: 실제 비용은 사용량에 따라 달라질 수 있습니다.
