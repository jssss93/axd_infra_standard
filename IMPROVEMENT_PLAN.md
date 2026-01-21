# 환경별 변수 중복 개선 계획

## 📋 현재 상황 분석

### 문제점
- **루트 `variables.tf`**: 모든 변수 정의 (711줄)
- **`env/dev/variables.tf`**: 거의 모든 변수 중복 정의 (686줄)
- **`env/prod/variables.tf`**: 일부 변수 중복 정의 (164줄)
- **`env/staging/variables.tf`**: 일부 변수 중복 정의 (164줄)

### 중복으로 인한 문제
1. **유지보수 어려움**: 변수 정의 변경 시 여러 파일 수정 필요
2. **일관성 저하**: 환경별로 변수 정의가 달라질 위험
3. **코드 중복**: 동일한 변수가 여러 곳에 정의됨
4. **확장성 저하**: 새 환경 추가 시 변수 정의 복사 필요

## 🎯 개선 목표

**"루트만 유지, 환경은 오버라이드만"**

- 루트 `variables.tf`에 모든 공통 변수 정의 유지
- 환경별 `variables.tf`는 환경별로 **오버라이드가 필요한 변수만** 정의
- Terraform의 변수 우선순위를 활용하여 환경별 값만 오버라이드

## 📐 개선 방안 상세

### 1단계: 변수 분류 및 분석

#### 1.1 공통 변수 (루트에 유지)
다음 변수들은 모든 환경에서 동일하게 사용되므로 루트에만 정의:
- 네이밍 규칙 변수: `project_name`, `environment`, `purpose`, `asset_management`, `sequence_number`
- 리소스 이름 변수: `resource_group_name`, `vnet_name`, `container_app_environment_name`
- 네트워크 변수: `vnet_address_space`, `dns_servers`, `subnets`
- Container Apps 변수: `container_apps`, `container_apps_subnet_id`
- Log Analytics 변수: `log_analytics_workspace_*`
- 서비스 활성화 플래그: `*_enabled` 변수들
- 서비스 설정: `*_config` 변수들
- 기타 공통 변수: `location`, `subscription_id`, `tags`, `common_tags`

#### 1.2 환경별 오버라이드 변수 (환경별로 정의)
환경별로 값이 달라질 수 있는 변수만 환경별 `variables.tf`에 정의:
- `environment`: 환경별 기본값 (dev, staging, prod)
- `subscription_id`: 환경별 구독 ID
- `location`: 환경별 리전 (선택적)
- `vnet_address_space`: 환경별 네트워크 주소 공간
- `subnets`: 환경별 서브넷 구성
- `container_apps`: 환경별 컨테이너 앱 구성
- 기타 환경별로 다른 값이 필요한 변수

### 2단계: 파일 구조 개선

#### 2.1 루트 `variables.tf` (변경 없음)
- 모든 공통 변수 정의 유지
- 기본값은 개발 환경 기준으로 설정

#### 2.2 환경별 `variables.tf` 구조

**Before (현재 - 중복 많음):**
```hcl
# env/dev/variables.tf (686줄)
variable "environment" { ... }
variable "project_name" { ... }
variable "purpose" { ... }
variable "asset_management" { ... }
variable "sequence_number" { ... }
variable "resource_group_name" { ... }
variable "vnet_name" { ... }
variable "container_app_environment_name" { ... }
variable "location" { ... }
variable "subscription_id" { ... }
variable "vnet_address_space" { ... }
variable "dns_servers" { ... }
variable "subnets" { ... }
variable "container_apps_subnet_id" { ... }
variable "container_apps" { ... }
variable "log_analytics_workspace_id" { ... }
variable "log_analytics_workspace_name" { ... }
variable "log_analytics_workspace_suffix" { ... }
variable "log_analytics_workspace_sku" { ... }
variable "log_analytics_retention_days" { ... }
variable "common_tags" { ... }
variable "tags" { ... }
variable "application_gateway_enabled" { ... }
variable "application_gateway_name" { ... }
variable "application_gateway_subnet_id" { ... }
variable "application_gateway_config" { ... }
# ... 600줄 이상의 중복 변수 정의
```

**After (개선 후 - 오버라이드만):**
```hcl
# env/dev/variables.tf (약 50-100줄)
# 환경별로 오버라이드가 필요한 변수만 정의

variable "environment" {
  description = "환경 이름"
  type        = string
  default     = "dev"  # dev 환경 기본값
}

variable "subscription_id" {
  description = "Azure Subscription ID (선택, 지정하지 않으면 기본 subscription 사용)"
  type        = string
  default     = null  # terraform.tfvars에서 제공
}

# 환경별로 다른 값이 필요한 변수만 추가
variable "vnet_address_space" {
  description = "Virtual Network address space"
  type        = list(string)
  # dev 환경 기본값 (terraform.tfvars에서 오버라이드 가능)
  default     = ["10.0.0.0/16"]
}

variable "subnets" {
  description = "Subnet configurations"
  type = map(object({
    name                        = optional(string)
    address_prefixes            = list(string)
    network_security_group_id   = optional(string)
    route_table_id              = optional(string)
    service_endpoints           = optional(list(string))
    service_endpoint_policy_ids = optional(list(string))
    delegation = optional(object({
      name = string
      service_delegation = object({
        name    = string
        actions = optional(list(string))
      })
    }))
  }))
  # terraform.tfvars에서 제공 (필수)
}

variable "container_apps" {
  description = "Container App configurations"
  type = map(object({
    name          = optional(string)
    image         = string
    cpu           = optional(number, 0.25)
    memory        = optional(string, "0.5Gi")
    min_replicas  = optional(number, 0)
    max_replicas  = optional(number, 10)
    revision_mode = optional(string, "Single")
    env_vars      = optional(map(string), {})
    secrets = optional(list(object({
      name        = string
      secret_name = string
    })), [])
    ingress = optional(object({
      external_enabled = optional(bool, true)
      target_port      = number
      transport        = optional(string, "auto")
      traffic_weight = optional(object({
        percentage      = number
        latest_revision = optional(bool, true)
      }))
    }))
    tags = optional(map(string), {})
  }))
  default = {}  # terraform.tfvars에서 제공
}

# 기타 환경별로 다른 값이 필요한 변수만 추가
# (대부분의 변수는 루트 variables.tf에서 상속)
```

**환경별 차이점 예시:**
```hcl
# env/staging/variables.tf
variable "environment" {
  default = "staging"  # staging 환경 기본값
}

variable "vnet_address_space" {
  default = ["10.1.0.0/16"]  # staging 환경 네트워크
}

# env/prod/variables.tf
variable "environment" {
  default = "prod"  # prod 환경 기본값
}

variable "vnet_address_space" {
  default = ["10.2.0.0/16"]  # prod 환경 네트워크
}
```

#### 2.3 환경별 `terraform.tfvars` 활용
환경별 실제 값은 `terraform.tfvars` 파일에서 관리:
- `terraform.tfvars.example`을 복사하여 `terraform.tfvars` 생성
- 환경별 실제 값 입력
- `.gitignore`에 포함되어 Git에 커밋되지 않음

### 3단계: 구현 단계

#### Phase 1: 분석 및 준비 (1일)
- [ ] 현재 변수 사용 현황 분석
- [ ] 환경별 변수 차이점 파악
- [ ] 오버라이드가 필요한 변수 목록 작성

#### Phase 2: 루트 변수 정리 (1일)
- [ ] 루트 `variables.tf` 검토 및 정리
- [ ] 기본값 설정 검토
- [ ] 변수 설명 및 타입 확인

#### Phase 3: 환경별 변수 파일 리팩토링 (2일)
- [ ] `env/dev/variables.tf` 리팩토링
  - 공통 변수 제거
  - 환경별 오버라이드 변수만 유지
- [ ] `env/prod/variables.tf` 리팩토링
  - 공통 변수 제거
  - 환경별 오버라이드 변수만 유지
- [ ] `env/staging/variables.tf` 리팩토링
  - 공통 변수 제거
  - 환경별 오버라이드 변수만 유지

#### Phase 4: 테스트 및 검증 (1일)
- [ ] 각 환경별로 `terraform validate` 실행
- [ ] 각 환경별로 `terraform plan` 실행하여 변경사항 확인
- [ ] 변수 참조 오류 확인 및 수정

#### Phase 5: 문서화 (0.5일)
- [ ] `env/README.md` 업데이트
- [ ] 변수 관리 가이드 작성
- [ ] 마이그레이션 가이드 작성

### 4단계: 마이그레이션 전략

#### 4.1 안전한 마이그레이션 순서
1. **개발 환경부터 시작**: `env/dev/variables.tf` 리팩토링
2. **스테이징 환경**: `env/staging/variables.tf` 리팩토링
3. **프로덕션 환경**: `env/prod/variables.tf` 리팩토링 (최종)

#### 4.2 롤백 계획
- 각 단계마다 Git 커밋하여 롤백 가능하도록 유지
- 변경 전 `terraform plan` 결과를 저장하여 비교
- 문제 발생 시 즉시 이전 버전으로 롤백

### 5단계: 예상 결과

#### 5.1 파일 크기 감소
- `env/dev/variables.tf`: 686줄 → 약 50-100줄 (85% 감소)
- `env/prod/variables.tf`: 164줄 → 약 30-50줄 (70% 감소)
- `env/staging/variables.tf`: 164줄 → 약 30-50줄 (70% 감소)

#### 5.2 유지보수성 향상
- 변수 정의 변경 시 루트 `variables.tf`만 수정
- 환경별 차이점이 명확하게 드러남
- 새 환경 추가 시 변수 정의 복사 불필요

#### 5.3 일관성 보장
- 모든 환경이 동일한 변수 정의 사용
- 환경별 차이는 오버라이드로만 관리
- 변수 타입 및 설명 일관성 유지

## 🔧 기술적 구현 세부사항

### Terraform 변수 우선순위 활용
Terraform은 다음 순서로 변수를 로드:
1. 환경 변수 (`TF_VAR_*`)
2. `terraform.tfvars` 파일
3. `*.auto.tfvars` 파일
4. `-var` 및 `-var-file` 옵션
5. 변수 정의의 `default` 값

환경별 `variables.tf`는 변수 정의만 제공하고, 실제 값은 `terraform.tfvars`에서 관리하는 것이 권장됩니다.

### 모듈 호출 구조 유지
환경별 `main.tf`는 변경 없이 유지:
- 루트 모듈 호출 시 `var.변수명` 형태로 전달
- Terraform이 자동으로 변수 우선순위에 따라 값 결정

### 변수 분석 결과

#### 환경별로 다른 값이 확인된 변수
다음 변수들은 환경별 `terraform.tfvars.example`에서 다른 값을 가지고 있음:

| 변수명 | Dev | Staging | Prod | 환경별 정의 필요 |
|--------|-----|---------|------|----------------|
| `environment` | "dev" | "staging" | "prod" | ✅ (기본값만) |
| `vnet_address_space` | ["10.0.0.0/16"] | ["10.1.0.0/16"] | ["10.2.0.0/16"] | ✅ |
| `subnets` | dev 구성 | staging 구성 | prod 구성 | ✅ |
| `container_apps` | dev 구성 | staging 구성 | prod 구성 | ✅ |
| `subscription_id` | 환경별 구독 | 환경별 구독 | 환경별 구독 | ✅ (기본값 null) |

#### 루트에서만 정의하면 되는 변수
다음 변수들은 모든 환경에서 동일한 타입과 구조를 사용하므로 루트에만 정의:

- 모든 `*_enabled` 플래그 변수
- 모든 `*_config` 설정 변수
- 모든 `*_name` 리소스 이름 변수 (기본값 null)
- `log_analytics_workspace_*` 변수들
- `common_tags`, `tags` 변수
- `location` (기본값 "koreacentral")
- 네이밍 규칙 변수 (`project_name`, `purpose`, `asset_management`, `sequence_number`)

### 마이그레이션 가이드

#### Step 1: 환경별 변수 파일 백업
```bash
# 각 환경별로 백업 생성
cp env/dev/variables.tf env/dev/variables.tf.backup
cp env/staging/variables.tf env/staging/variables.tf.backup
cp env/prod/variables.tf env/prod/variables.tf.backup
```

#### Step 2: Dev 환경부터 리팩토링
```bash
cd env/dev

# 1. 현재 변수 사용 현황 확인
grep -r "var\." main.tf

# 2. terraform.tfvars.example에서 실제 사용되는 변수 확인
cat terraform.tfvars.example

# 3. variables.tf에서 오버라이드가 필요한 변수만 추출
# - environment (기본값 "dev")
# - subscription_id (기본값 null)
# - vnet_address_space (기본값 ["10.0.0.0/16"])
# - subnets (필수, 기본값 없음)
# - container_apps (기본값 {})
# - 기타 환경별로 다른 값이 필요한 변수만
```

#### Step 3: 새로운 variables.tf 작성
환경별 `variables.tf`를 다음과 같이 작성:

**env/dev/variables.tf 예시:**
```hcl
# 환경별 오버라이드 변수만 정의
# 나머지는 루트 variables.tf에서 상속

variable "environment" {
  description = "환경 이름"
  type        = string
  default     = "dev"
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  default     = null
}

variable "vnet_address_space" {
  description = "Virtual Network address space"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnets" {
  description = "Subnet configurations"
  type = map(object({
    name                        = optional(string)
    address_prefixes            = list(string)
    network_security_group_id   = optional(string)
    route_table_id              = optional(string)
    service_endpoints           = optional(list(string))
    service_endpoint_policy_ids = optional(list(string))
    delegation = optional(object({
      name = string
      service_delegation = object({
        name    = string
        actions = optional(list(string))
      })
    }))
  }))
}

variable "container_apps_subnet_id" {
  description = "Subnet key for Container Apps"
  type        = string
  default     = null
}

variable "container_apps" {
  description = "Container App configurations"
  type = map(object({
    name          = optional(string)
    image         = string
    cpu           = optional(number, 0.25)
    memory        = optional(string, "0.5Gi")
    min_replicas  = optional(number, 0)
    max_replicas  = optional(number, 10)
    revision_mode = optional(string, "Single")
    env_vars      = optional(map(string), {})
    secrets = optional(list(object({
      name        = string
      secret_name = string
    })), [])
    ingress = optional(object({
      external_enabled = optional(bool, true)
      target_port      = number
      transport        = optional(string, "auto")
      traffic_weight = optional(object({
        percentage      = number
        latest_revision = optional(bool, true)
      }))
    }))
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
```

#### Step 4: 검증
```bash
# 각 환경에서 검증
cd env/dev
terraform init -upgrade
terraform validate
terraform plan  # 변경사항 확인 (변수 관련 오류 없어야 함)
```

#### Step 5: 다른 환경에도 적용
Staging과 Prod 환경에도 동일한 방식으로 적용 (기본값만 변경)

## 📝 체크리스트

### 개발 환경 (`env/dev`)
- [ ] `variables.tf`에서 공통 변수 제거
- [ ] 환경별 오버라이드 변수만 유지
- [ ] `terraform.tfvars.example` 확인
- [ ] `terraform validate` 통과
- [ ] `terraform plan` 정상 실행

### 스테이징 환경 (`env/staging`)
- [ ] `variables.tf`에서 공통 변수 제거
- [ ] 환경별 오버라이드 변수만 유지
- [ ] `terraform.tfvars.example` 확인
- [ ] `terraform validate` 통과
- [ ] `terraform plan` 정상 실행

### 프로덕션 환경 (`env/prod`)
- [ ] `variables.tf`에서 공통 변수 제거
- [ ] 환경별 오버라이드 변수만 유지
- [ ] `terraform.tfvars.example` 확인
- [ ] `terraform validate` 통과
- [ ] `terraform plan` 정상 실행

## 🚨 주의사항

### 변수 정의 관련
1. **변수 기본값 변경 시 주의**: 루트 `variables.tf`의 기본값 변경은 모든 환경에 영향을 미침
2. **필수 변수 처리**: 환경별로 필수인 변수는 `default = null`로 설정하고 `terraform.tfvars`에서 반드시 제공
3. **변수 타입 일치**: 환경별 변수 타입은 루트 변수 타입과 반드시 일치해야 함
4. **변수 이름 일치**: 환경별 변수 이름은 루트 변수 이름과 반드시 일치해야 함

### 마이그레이션 시 주의
1. **단계별 진행**: 한 번에 모든 환경을 변경하지 말고, 환경별로 순차적으로 진행
2. **백업 필수**: 변경 전 반드시 Git 커밋 또는 백업 생성
3. **검증 필수**: 각 단계마다 `terraform validate` 및 `terraform plan` 실행
4. **변수 참조 확인**: `main.tf`에서 사용하는 모든 변수가 정의되어 있는지 확인

### 운영 시 주의
1. **변수 추가 시**: 새 변수를 추가할 때는 루트 `variables.tf`에 먼저 추가
2. **환경별 차이**: 환경별로 다른 값이 필요한 경우에만 환경별 `variables.tf`에 추가
3. **문서화**: 변수 추가 시 README.md에 사용법 문서화

## 📊 변수 정의 비교표

### 현재 vs 개선 후 비교

| 구분 | 현재 | 개선 후 | 감소율 |
|------|------|---------|--------|
| **루트 variables.tf** | 711줄 (모든 변수) | 711줄 (변경 없음) | 0% |
| **env/dev/variables.tf** | 686줄 (거의 모든 변수 중복) | ~50-100줄 (오버라이드만) | **85-90%** |
| **env/staging/variables.tf** | 164줄 (일부 변수 중복) | ~30-50줄 (오버라이드만) | **70-80%** |
| **env/prod/variables.tf** | 164줄 (일부 변수 중복) | ~30-50줄 (오버라이드만) | **70-80%** |
| **총 변수 정의 줄 수** | 1,725줄 | ~850줄 | **50%** |

### 환경별 변수 정의 필요 여부

| 변수명 | 루트 정의 | Dev 정의 | Staging 정의 | Prod 정의 | 비고 |
|--------|----------|----------|-------------|-----------|------|
| `environment` | ✅ | ✅ (기본값) | ✅ (기본값) | ✅ (기본값) | 환경별 기본값만 |
| `project_name` | ✅ | ❌ | ❌ | ❌ | 루트에서만 |
| `purpose` | ✅ | ❌ | ❌ | ❌ | 루트에서만 |
| `subscription_id` | ✅ | ✅ (기본값 null) | ✅ (기본값 null) | ✅ (기본값 null) | 환경별 구독 ID |
| `location` | ✅ | ❌ | ❌ | ❌ | 루트에서만 (기본값 "koreacentral") |
| `vnet_address_space` | ✅ | ✅ (기본값) | ✅ (기본값) | ✅ (기본값) | 환경별 네트워크 |
| `subnets` | ✅ | ✅ (필수) | ✅ (필수) | ✅ (필수) | 환경별 구성 |
| `container_apps` | ✅ | ✅ (기본값 {}) | ✅ (기본값 {}) | ✅ (기본값 {}) | 환경별 구성 |
| `*_enabled` | ✅ | ❌ | ❌ | ❌ | 루트에서만 |
| `*_config` | ✅ | ❌ | ❌ | ❌ | 루트에서만 |
| `log_analytics_*` | ✅ | ❌ | ❌ | ❌ | 루트에서만 |

**✅ = 정의 필요, ❌ = 정의 불필요 (루트에서 상속)**

## 📚 참고 자료

- [Terraform 변수 문서](https://developer.hashicorp.com/terraform/language/values/variables)
- [Terraform 모듈 문서](https://developer.hashicorp.com/terraform/language/modules)
- 프로젝트 내 `env/README.md`

## 📅 일정

| 단계 | 작업 | 예상 소요 시간 | 담당 |
|------|------|---------------|------|
| Phase 1 | 분석 및 준비 | 1일 | - |
| Phase 2 | 루트 변수 정리 | 1일 | - |
| Phase 3 | 환경별 변수 리팩토링 | 2일 | - |
| Phase 4 | 테스트 및 검증 | 1일 | - |
| Phase 5 | 문서화 | 0.5일 | - |
| **총계** | | **5.5일** | |

## ✅ 성공 기준

1. 모든 환경에서 `terraform validate` 통과
2. 모든 환경에서 `terraform plan` 정상 실행
3. 환경별 `variables.tf` 파일 크기 70% 이상 감소
4. 변수 정의 중복 제거 완료
5. 문서화 완료

## 📝 요약

### 핵심 원칙
**"루트만 유지, 환경은 오버라이드만"**

### 주요 변경사항
1. **루트 `variables.tf`**: 모든 공통 변수 정의 유지 (변경 없음)
2. **환경별 `variables.tf`**: 환경별로 오버라이드가 필요한 변수만 정의
   - Dev: ~686줄 → ~50-100줄 (85-90% 감소)
   - Staging: ~164줄 → ~30-50줄 (70-80% 감소)
   - Prod: ~164줄 → ~30-50줄 (70-80% 감소)

### 기대 효과
1. **유지보수성 향상**: 변수 정의 변경 시 루트만 수정
2. **일관성 보장**: 모든 환경이 동일한 변수 정의 사용
3. **코드 중복 제거**: 변수 정의 중복 50% 이상 감소
4. **확장성 향상**: 새 환경 추가 시 변수 정의 복사 불필요

### 실행 순서
1. 분석 및 준비 (1일)
2. 루트 변수 정리 (1일)
3. 환경별 변수 리팩토링 (2일) - Dev → Staging → Prod 순서
4. 테스트 및 검증 (1일)
5. 문서화 (0.5일)

**총 예상 소요 시간: 5.5일**
