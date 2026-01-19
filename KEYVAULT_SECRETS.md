# Key Vault Secret 관리 가이드

## 개요

PaaS 서비스의 접속 정보 및 패스워드를 Azure Key Vault Secret으로 자동 관리합니다.

## 저장되는 Secret 목록

### PostgreSQL
- `postgresql-password`: 관리자 패스워드
- `postgresql-fqdn`: 서버 FQDN
- `postgresql-admin-login`: 관리자 로그인 이름

### Cosmos DB
- `cosmosdb-endpoint`: Cosmos DB 엔드포인트 URL
- `cosmosdb-primary-key`: Primary Access Key
- `cosmosdb-secondary-key`: Secondary Access Key

### Azure Container Registry (ACR)
- `acr-login-server`: ACR 로그인 서버 주소
- `acr-admin-username`: 관리자 사용자명 (admin_enabled=true인 경우)
- `acr-admin-password`: 관리자 패스워드 (admin_enabled=true인 경우)

### Azure OpenAI
- `openai-endpoint`: OpenAI 엔드포인트 URL
- `openai-primary-key`: Primary Access Key
- `openai-secondary-key`: Secondary Access Key

### AI Foundry
- `foundry-endpoint`: Foundry 엔드포인트 URL
- `foundry-primary-key`: Primary Access Key
- `foundry-secondary-key`: Secondary Access Key

## 사용 방법

### Terraform에서 Secret 참조

```hcl
# Key Vault Secret 참조 예시
data "azurerm_key_vault_secret" "postgresql_password" {
  name         = "postgresql-password"
  key_vault_id = module.infra.key_vault_id
}

# 사용 예시
resource "azurerm_container_app" "app" {
  # ...
  secret {
    name  = "DB_PASSWORD"
    value = data.azurerm_key_vault_secret.postgresql_password.value
  }
}
```

### Azure CLI에서 Secret 조회

```bash
# Secret 값 조회
az keyvault secret show \
  --vault-name <key-vault-name> \
  --name postgresql-password \
  --query value -o tsv
```

### 애플리케이션에서 Secret 사용

#### Container Apps에서 Key Vault Secret 참조

```hcl
resource "azurerm_container_app" "app" {
  # ...
  secret {
    name  = "DB_PASSWORD"
    value = "@Microsoft.KeyVault(SecretUri=https://<key-vault-name>.vault.azure.net/secrets/postgresql-password/)"
  }
}
```

## 주의사항

### Public Network Access 비활성화 시

Key Vault의 `public_network_access_enabled = false`로 설정된 경우:
- Terraform 실행 환경이 Private Endpoint를 통해 Key Vault에 접근할 수 있어야 함
- 또는 일시적으로 `public_network_access_enabled = true`로 변경하여 Secret 생성 후 다시 비활성화

### RBAC 권한

Key Vault가 RBAC 모드를 사용하는 경우:
- Terraform 실행 주체에 "Key Vault Secrets Officer" 또는 "Key Vault Secrets User" 역할이 필요
- Secret을 읽는 애플리케이션에도 적절한 RBAC 권한 부여 필요

## 자동 생성

모든 Secret은 `modules/services/infra/main.tf`에서 자동으로 생성됩니다:
- PaaS 서비스가 생성되면 자동으로 해당 Secret이 Key Vault에 저장됨
- Secret 이름은 일관된 네이밍 규칙을 따름
- 모든 Secret은 `sensitive = true`로 처리되어 Terraform 출력에서 숨겨짐
