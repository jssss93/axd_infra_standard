# 모듈 구조 문서

## 새로운 모듈 폴더 구조

```
modules/
├── foundation/          # 기본 인프라
│   └── rg/             # Resource Group
│
├── networking/          # 네트워크 관련
│   ├── core/           # VNet, Subnets, Application Gateway (통합)
│   ├── gateway/        # Application Gateway (독립 모듈)
│   ├── pe/             # Private Endpoints + Private DNS Zones 통합
│   ├── private-dns-zone/  # Private DNS Zone (개별 모듈)
│   ├── private-endpoint/  # Private Endpoint (개별 모듈)
│   └── legacy-network/    # 레거시 네트워크 모듈 (deprecated)
│
├── compute/            # 컴퓨팅 리소스
│   └── container-apps/  # Container Apps, VM, Log Analytics
│
└── services/           # PaaS 서비스들
    ├── acr/            # Container Registry
    ├── keyvault/       # Key Vault
    ├── cosmos/         # Cosmos DB
    ├── postgres/       # PostgreSQL
    ├── foundry/        # AI Foundry
    ├── openai/         # OpenAI
    └── infra/          # 통합 모듈 (위 서비스들을 통합 관리)
```

## 모듈 경로 매핑

### 루트 모듈 (main.tf)
- `module.rg` → `./modules/foundation/rg`
- `module.networking_core` → `./modules/networking/core`
- `module.compute` → `./modules/compute/container-apps`
- `module.infra` → `./modules/services/infra`
- `module.networking_pe` → `./modules/networking/pe`

### 서비스 통합 모듈 (modules/services/infra/main.tf)
- `module.acr` → `../acr`
- `module.keyvault` → `../keyvault`
- `module.cosmos` → `../cosmos`
- `module.postgres` → `../postgres`
- `module.foundry` → `../foundry`
- `module.openai` → `../openai`

## 구조의 장점

1. **명확한 계층 구조**: Foundation → Networking → Compute → Application → Services
2. **확장성**: 새로운 모듈을 적절한 카테고리 폴더에 추가 가능
3. **유지보수성**: 관련 모듈들이 그룹화되어 관리 용이
4. **가독성**: 프로젝트 구조를 한눈에 파악 가능

## Deprecated 모듈

- `modules/networking/legacy-network/` - `modules/networking/core/`로 대체됨 (레거시 호환성을 위해 보관)
