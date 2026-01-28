# 빌드 명령어:
# docker build -t nexus.openaxd.com:5001/baseimage/docker:24-build-tools -f Dockerfile .
# 푸시 명령어:
# docker push nexus.openaxd.com:5001/baseimage/docker:24-build-tools

FROM docker:24

# 기본 패키지
RUN apk add --no-cache \
    python3 \
    py3-pip \
    bash \
    curl \
    wget \
    unzip

# ===== Terraform 설치 (공식 바이너리) =====
ARG TERRAFORM_VERSION=1.14.3

RUN curl -fsSL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    -o /tmp/terraform.zip \
 && unzip /tmp/terraform.zip -d /usr/local/bin \
 && rm -f /tmp/terraform.zip \
 && terraform version

# ===== Azure CLI =====
RUN python3 -m venv /opt/az-venv \
 && /opt/az-venv/bin/pip install --upgrade pip \
 && /opt/az-venv/bin/pip install azure-cli

ENV PATH="/opt/az-venv/bin:$PATH"

# ===== Trivy 설치 =====
RUN curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

# ===== Infracost 설치 =====
RUN curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh | sh

# 버전 확인
RUN az --version \
 && terraform version \
 && docker --version \
 && trivy --version \
 && infracost --version