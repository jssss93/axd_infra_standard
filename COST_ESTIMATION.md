# Infracost 비용 계산 결과

이 문서는 Infracost를 사용하여 Terraform 배포 비용을 계산한 최종 결과입니다.

## 실행 명령어

```bash
cd env/dev
infracost breakdown --path . \
  --terraform-plan-flags="-var-file=terraform.tfvars" \
  --terraform-var-file=terraform.tfvars
```

## 비용 요약

### 월간 예상 비용

| 항목 | Baseline Cost | Usage Cost* | Total Cost |
|------|---------------|-------------|------------|
| **전체 프로젝트** | **$201** | **$6** | **$206.59** |

*Usage costs는 실제 사용량에 따라 달라질 수 있습니다.

## 리소스별 상세 비용

### 1. Application Gateway

| 리소스 | 항목 | 월간 수량 | 단위 | 월간 비용 |
|--------|------|----------|------|----------|
| `azurerm_application_gateway.this` | Gateway usage (basic v2) | 730 | hours | **$197.10** |
| | V2 capacity units (basic) | 730 | CU | **$5.84** |
| **소계** | | | | **$202.94** |

**설정 정보:**
- SKU: `Standard_v2`
- Capacity: `1` instance
- Location: `koreacentral`

**비용 설명:**
- Gateway usage: Application Gateway v2 기본 사용료 (시간당 $0.27)
- Capacity units: 용량 단위 비용 (CU당 $0.008)

### 2. Public IP

| 리소스 | 항목 | 월간 수량 | 단위 | 월간 비용 |
|--------|------|----------|------|----------|
| `azurerm_public_ip.this[0]` | IP address (static, regional) | 730 | hours | **$3.65** |

**설정 정보:**
- SKU: `Standard`
- Allocation Method: `Static`
- Location: `koreacentral`

**비용 설명:**
- Static Public IP 주소 사용료 (시간당 $0.005)

### 3. Log Analytics Workspace

| 리소스 | 항목 | 비용 정보 |
|--------|------|----------|
| `azurerm_log_analytics_workspace.this[0]` | Log data ingestion | 가격 정보 없음 (사용량 기반) |
| | Log data export | **$0.14 per GB** |
| | Basic log data ingestion | **$0.68 per GB** |
| | Basic log search queries | **$0.00675 per GB searched** |
| | Archive data | **$0.027 per GB** |
| | Archive data restored | **$0.14 per GB** |
| | Archive data searched | **$0.00675 per GB** |

**설정 정보:**
- SKU: `PerGB2018`
- Retention Days: `30`
- Location: `koreacentral`

**비용 설명:**
- Log Analytics Workspace는 사용량 기반 과금입니다
- 월간 예상 비용은 로그 수집량에 따라 달라집니다
- 일반적인 개발 환경: **$10-50/월** (로그량에 따라)

### 4. Container Apps (미지원)

Container Apps는 현재 Infracost에서 완전히 지원되지 않습니다. 수동으로 비용을 추정해야 합니다.

**예상 비용 (수동 계산):**

| 항목 | 설정 | 예상 비용 |
|------|------|----------|
| Container App Environment | Consumption Plan | 사용량 기반 |
| Container App (webapp) | CPU: 0.25, Memory: 0.5Gi, Replicas: 0-2 | **$5-30/월** |

**비용 설명:**
- Container Apps는 Consumption Plan으로 사용한 만큼만 과금됩니다
- vCPU 시간당: 약 $0.000012/vCPU-second
- Memory 시간당: 약 $0.0000015/GB-second
- 최소 요금: 없음 (사용하지 않으면 비용 없음)

### 5. 기타 무료 리소스

다음 리소스들은 Azure에서 무료로 제공됩니다:

- Resource Group (`azurerm_resource_group`)
- Virtual Network (`azurerm_virtual_network`)
- Subnets (`azurerm_subnet`)
- Container App Environment (인프라 자체는 무료, 사용량만 과금)

## 총 예상 비용 (월간)

### Infracost로 계산된 비용

| 카테고리 | 비용 |
|---------|------|
| Application Gateway | $202.94 |
| Public IP | $3.65 |
| **계산된 합계** | **$206.59** |

### 수동 추가 비용 (추정)

| 카테고리 | 비용 |
|---------|------|
| Log Analytics Workspace | $10-50 (사용량 기반) |
| Container Apps | $5-30 (사용량 기반) |
| **추정 합계** | **$15-80** |

### **총 예상 비용: $221-286/월**

## 비용 최적화 권장사항

### 1. Application Gateway 비용 절감

- **현재**: Standard_v2, Capacity 1 → **$202.94/월**
- **권장**: 
  - 개발 환경: Application Gateway 비활성화 고려
  - Container Apps 직접 접근 사용 (비용 $0)
  - 예상 절감액: **$202.94/월**

### 2. Container Apps 비용 최적화

- Min replicas를 0으로 설정 (현재 설정됨)
- 사용하지 않을 때 자동으로 스케일 다운되어 비용 없음
- CPU/Memory를 필요한 만큼만 할당

### 3. Log Analytics 비용 최적화

- Retention days를 30일에서 7일로 줄이면 스토리지 비용 절감
- 불필요한 로그 수집 비활성화
- 예상 절감액: **$5-20/월**

## 비용 변동 요인

### 증가 요인

1. **트래픽 증가**
   - Application Gateway 데이터 전송 비용 증가
   - Container Apps 사용량 증가

2. **스케일 아웃**
   - Container Apps replicas 증가
   - Application Gateway capacity 증가

3. **로그 증가**
   - Log Analytics 데이터 수집량 증가
   - Retention 기간 연장

### 감소 요인

1. **개발 환경 최적화**
   - Application Gateway 비활성화
   - Container Apps 최소화

2. **사용량 기반 최적화**
   - Auto-scaling 설정
   - Idle 상태 자동 스케일 다운

## 비용 모니터링

### Azure Cost Management

1. Azure Portal → Cost Management + Billing
2. Cost analysis에서 리소스별 비용 확인
3. Budget 설정으로 비용 알림 구성

### Infracost Cloud

Infracost Cloud를 사용하면 더 정확한 사용량 기반 비용 추정이 가능합니다:

```bash
infracost auth login
infracost breakdown --path . --sync-usage-file
```

## 참고사항

- 위 비용은 **한국 중부 리전 (koreacentral)** 기준입니다
- 실제 비용은 사용량, 트래픽, 데이터 전송량에 따라 달라질 수 있습니다
- Container Apps는 Infracost에서 완전히 지원되지 않아 수동 추정이 필요합니다
- Log Analytics 비용은 로그 수집량에 따라 크게 달라질 수 있습니다

## 업데이트 날짜

- 계산 일시: 2025-01-16
- Infracost 버전: v0.10.42
- 설정: Standard_v2, Capacity 1
