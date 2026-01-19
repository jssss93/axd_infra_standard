# 모듈 폴더 구조 재구성 계획

## 현재 구조
```
modules/
├── acr/
├── agw/
├── compute/
├── cosmos/
├── foundry/
├── infra/
├── keyvault/
├── network/          (deprecated)
├── networking-core/
├── networking-pe/
├── openai/
├── postgres/
├── private-dns-zone/
├── private-endpoint/
└── rg/
```

## 제안하는 새로운 구조

### 옵션 1: 계층별 구조 (권장)
```
modules/
├── foundation/          # 기본 인프라
│   └── rg/
├── networking/         # 네트워크 관련
│   ├── core/           # networking-core
│   ├── pe/             # networking-pe
│   ├── private-dns-zone/
│   └── private-endpoint/
├── compute/            # 컴퓨팅 리소스
│   └── container-apps/  # compute
├── application/        # 애플리케이션 레벨
│   └── gateway/        # agw
└── services/           # PaaS 서비스들
    ├── acr/
    ├── keyvault/
    ├── cosmos/
    ├── postgres/
    ├── foundry/
    ├── openai/
    └── infra/          # 통합 모듈
```

### 옵션 2: 기능별 구조
```
modules/
├── foundation/
│   └── rg/
├── networking/
│   ├── core/
│   ├── pe/
│   ├── dns/
│   └── endpoints/
├── compute/
│   └── container-apps/
├── application/
│   └── gateway/
└── infrastructure/
    ├── registry/       # acr
    ├── security/       # keyvault
    ├── database/       # cosmos, postgres
    ├── ai/            # foundry, openai
    └── infra/         # 통합
```

## 권장 사항: 옵션 1

이유:
- 명확한 계층 구조
- 확장성 좋음
- 유지보수 용이

## 마이그레이션 계획

1. 새 디렉토리 구조 생성
2. 모듈 파일 이동
3. main.tf 및 관련 파일의 source 경로 업데이트
4. terraform init 재실행
5. terraform plan으로 검증

## 영향받는 파일

- `main.tf` - 모든 모듈 source 경로
- `modules/infra/main.tf` - 하위 모듈 source 경로
- `env/dev/main.tf` - 루트 모듈 source 경로 (변경 없음)
