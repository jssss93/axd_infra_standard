# 코드 개선 사항

## 1. 🔴 Critical: Deprecated 속성 수정

### 문제
- `enable_rbac_authorization` 속성이 deprecated되었고 v5.0에서 제거될 예정
- 현재 경고 메시지가 계속 표시됨

### 위치
- `modules/services/keyvault/main.tf:13`
- `modules/services/keyvault/variables.tf:45`
- `modules/services/infra/main.tf:41`

### 수정 방법
```terraform
# 변경 전
enable_rbac_authorization = var.enable_rbac_authorization

# 변경 후
rbac_authorization_enabled = var.rbac_authorization_enabled
```

### 영향 범위
- `modules/services/keyvault/main.tf`
- `modules/services/keyvault/variables.tf`
- `modules/services/infra/main.tf`
- `modules/services/infra/variables.tf`
- `variables.tf`
- `env/dev/variables.tf`

---

## 2. 🟡 Important: Key Vault Secret lifecycle 불일치

### 문제
- 일부 Key Vault Secret에는 `lifecycle { ignore_changes = all }`가 있지만
- `acr_admin_username`, `acr_admin_password`에는 없음
- 일관성 문제 및 향후 변경 시 예상치 못한 동작 가능

### 위치
- `modules/services/infra/main.tf:176-200`

### 수정 방법
```terraform
resource "azurerm_key_vault_secret" "acr_admin_username" {
  # ... existing code ...
  
  lifecycle {
    ignore_changes = all
  }
  
  depends_on = [module.keyvault, module.acr]
}

resource "azurerm_key_vault_secret" "acr_admin_password" {
  # ... existing code ...
  
  lifecycle {
    ignore_changes = all
  }
  
  depends_on = [module.keyvault, module.acr]
}
```

---

## 3. 🟡 Important: Storage Account public_network_access 하드코딩

### 문제
- Foundry용 Storage Account의 `public_network_access_enabled`가 하드코딩되어 있음
- 변수로 관리하는 것이 유연성과 일관성 측면에서 좋음

### 위치
- `modules/services/infra/main.tf:346`

### 수정 방법
```terraform
# 변경 전
resource "azurerm_storage_account" "foundry" {
  # ...
  public_network_access_enabled = false  # 하드코딩
  # ...
}

# 변경 후
resource "azurerm_storage_account" "foundry" {
  # ...
  public_network_access_enabled = lookup(var.foundry_config, "storage_account_public_network_access_enabled", false)
  # ...
}
```

또는 `foundry_config`에 `storage_account_public_network_access_enabled` 변수 추가

---

## 4. 🟢 Medium: Foundry public_network_access 상태 불일치

### 문제
- `terraform.tfvars`에서 `public_network_access_enabled = false`로 설정했지만
- 실제 리소스는 `public_network_access = "Enabled"`로 생성됨
- terraform apply를 통해 "Disabled"로 변경 필요

### 위치
- `env/dev/terraform.tfvars`의 `foundry_config`
- 실제 리소스 상태 확인 필요

### 확인 방법
```bash
terraform plan | grep -A 5 "azurerm_ai_foundry.foundry"
```

### 수정 방법
- `terraform apply` 실행하여 상태 동기화

---

## 5. 🟢 Medium: 코드 중복 (Key Vault Secret 생성)

### 문제
- Key Vault Secret 생성 로직이 반복됨
- 유지보수 시 실수 가능성 증가

### 위치
- `modules/services/infra/main.tf:55-270`

### 개선 방안 (선택사항)
- `locals` 블록을 사용하여 공통 로직 추출
- 또는 별도 모듈로 분리 (복잡도 증가 가능)

예시:
```terraform
locals {
  key_vault_secrets = {
    postgresql_password = {
      name  = "postgresql-password"
      value = var.postgresql_config.administrator_password
      source = "postgres"
    }
    # ... 다른 secrets ...
  }
}

resource "azurerm_key_vault_secret" "this" {
  for_each = local.key_vault_secrets
  
  name         = each.value.name
  value        = each.value.value
  content_type = "text/plain"
  key_vault_id = module.keyvault[0].id
  
  lifecycle {
    ignore_changes = all
  }
}
```

---

## 6. 🟢 Low: 변수 기본값 일관성

### 문제
- `public_network_access_enabled`의 기본값이 모듈마다 다름
- 일부는 `true`, 일부는 `false`

### 위치
- `modules/services/infra/variables.tf`의 여러 `public_network_access_enabled` 기본값

### 권장사항
- 보안 정책에 따라 일관된 기본값 설정 (권장: `false`)

---

## 7. 🟢 Low: Foundry 모듈의 identity_type 기본값

### 문제
- `modules/services/foundry/variables.tf:35`에서 `identity_type` 기본값이 `"SystemAssigned"`
- 하지만 `identity_type`이 `null`일 때 identity 블록이 생성되지 않음
- 기본값과 로직이 일치하지 않을 수 있음

### 확인 필요
- `identity_type = null`일 때와 `identity_type = "SystemAssigned"`일 때의 동작 확인

---

## 우선순위별 수정 계획

### 즉시 수정 필요 (Critical)
1. ✅ Deprecated 속성 수정 (`enable_rbac_authorization` → `rbac_authorization_enabled`)

### 단기 개선 (Important)
2. ✅ Key Vault Secret lifecycle 일관성 확보
3. ✅ Storage Account public_network_access 변수화

### 중기 개선 (Medium)
4. ✅ Foundry public_network_access 상태 동기화
5. ⚠️ Key Vault Secret 생성 로직 리팩토링 (선택사항)

### 장기 개선 (Low)
6. ⚠️ 변수 기본값 일관성 확보
7. ⚠️ Foundry identity_type 로직 검토
