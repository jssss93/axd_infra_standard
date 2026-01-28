#!/bin/bash

# 기존 프로젝트의 모듈 참조를 Git 레포지토리 참조로 변경하는 스크립트
# 사용법: ./scripts/update-module-references.sh [모듈 레포지토리 URL] [버전 태그]

set -e

# 기본값 설정
MODULE_REPO_URL="${1:-git::https://github.com/your-org/terraform-azure-modules.git}"
MODULE_VERSION="${2:-v1.0.0}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=========================================="
echo "모듈 참조 업데이트 스크립트"
echo "=========================================="
echo "프로젝트 루트: $PROJECT_ROOT"
echo "모듈 레포지토리: $MODULE_REPO_URL"
echo "버전: $MODULE_VERSION"
echo ""

# 백업 디렉토리 생성
BACKUP_DIR="$PROJECT_ROOT/.backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "1. 백업 생성 중: $BACKUP_DIR"

# main.tf 백업 및 변경
if [ -f "$PROJECT_ROOT/main.tf" ]; then
    cp "$PROJECT_ROOT/main.tf" "$BACKUP_DIR/main.tf"
    echo "   - main.tf 백업 완료"
    
    # 로컬 경로를 Git 레포지토리 경로로 변경
    sed -i.tmp "s|source = \"./modules/|source = \"${MODULE_REPO_URL}//modules/|g" "$PROJECT_ROOT/main.tf"
    # 버전 태그 추가
    sed -i.tmp "s|//modules/\([^\"]*\)\"|//modules/\1?ref=${MODULE_VERSION}\"|g" "$PROJECT_ROOT/main.tf"
    rm -f "$PROJECT_ROOT/main.tf.tmp"
    echo "   - main.tf 업데이트 완료"
fi

# env 디렉토리의 main.tf 파일들 변경
if [ -d "$PROJECT_ROOT/env" ]; then
    echo "2. env 디렉토리 파일 업데이트 중..."
    
    find "$PROJECT_ROOT/env" -name "main.tf" -type f | while read -r file; do
        # 백업
        rel_path="${file#$PROJECT_ROOT/}"
        backup_path="$BACKUP_DIR/$rel_path"
        mkdir -p "$(dirname "$backup_path")"
        cp "$file" "$backup_path"
        
        # 상대 경로 변경 (../modules/ 또는 ../../modules/)
        sed -i.tmp "s|source = \"../modules/|source = \"${MODULE_REPO_URL}//modules/|g" "$file"
        sed -i.tmp "s|source = \"../../modules/|source = \"${MODULE_REPO_URL}//modules/|g" "$file"
        # 버전 태그 추가
        sed -i.tmp "s|//modules/\([^\"]*\)\"|//modules/\1?ref=${MODULE_VERSION}\"|g" "$file"
        rm -f "$file.tmp"
        
        echo "   - $rel_path 업데이트 완료"
    done
fi

echo ""
echo "=========================================="
echo "완료!"
echo "=========================================="
echo "모든 모듈 참조가 업데이트되었습니다."
echo "백업 위치: $BACKUP_DIR"
echo ""
echo "변경사항 확인:"
echo "  git diff main.tf"
echo ""
echo "변경사항 되돌리기:"
echo "  cp $BACKUP_DIR/main.tf main.tf"
echo ""
