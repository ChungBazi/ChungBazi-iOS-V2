#!/bin/sh

#  ci_post_clone.sh
#  Xcode Cloud가 소스를 클론한 직후, 의존성 해석·빌드 전에 실행된다.
#
#  이 레포는 .xcworkspace/.xcodeproj, *.xcconfig, GoogleService-Info.plist를 커밋하지 않는다
#  (.gitignore 참고). 따라서 Xcode Cloud가 빌드를 시작하려면 여기서 전부 만들어야 한다.
#
#    1. 릴리즈 태그 검증
#    2. mise로 .mise.toml에 핀된 Tuist 설치 → tuist install(SPM)
#    3. Xcode Cloud secret으로 xcconfig·GoogleService-Info.plist 생성
#    4. 버전·빌드 번호를 주입해 tuist generate
#
#  필요한 Xcode Cloud 환경 변수(secret): docs/GIT_FLOW_GUIDELINES.md 참고

set -e

cd "$CI_PRIMARY_REPOSITORY_PATH"

# 태그명이 곧 마케팅 버전이다. 태그 없이(브랜치에서) 실행하면 Project.swift 기본값으로
# 아카이브되어 잘못된 버전이 업로드되므로, 도구 설치 전에 바로 막는다.
if [ -z "${CI_TAG:-}" ]; then
    echo "릴리즈 태그 없이 실행되었습니다. 브랜치가 아니라 릴리즈 태그를 선택해 실행하세요." >&2
    exit 1
fi
if ! printf '%s\n' "$CI_TAG" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'; then
    echo "유효하지 않은 릴리즈 태그: $CI_TAG (예: 2.1.0)" >&2
    exit 1
fi
export TUIST_MARKETING_VERSION="$CI_TAG"

# 값이 비어 있으면 빈 키로 빌드된 앱이 그대로 업로드되므로 빌드 전에 막는다.
for name in BASE_URL KAKAO_NATIVE_APP_KEY AMPLITUDE_API_KEY GOOGLE_SERVICE_INFO_PLIST_BASE64; do
    eval "value=\${$name:-}"
    if [ -z "$value" ]; then
        echo "Xcode Cloud 환경 변수 $name 이(가) 비어 있습니다." >&2
        exit 1
    fi
done

echo "=== [ci_post_clone] mise 설치 ==="
curl -fsSL https://mise.run | sh
export PATH="$HOME/.local/bin:$PATH"
export MISE_YES=1
mise trust "$CI_PRIMARY_REPOSITORY_PATH/.mise.toml"

echo "=== [ci_post_clone] 핀된 도구 설치 (.mise.toml) ==="
mise install

echo "=== [ci_post_clone] SPM 의존성 해석 (tuist install) ==="
mise exec -- tuist install

echo "=== [ci_post_clone] xcconfig 생성 ==="
CONFIG_DIR="Projects/ChungBazi/Configurations"
mkdir -p "$CONFIG_DIR"

# xcconfig에서 `//`는 주석 시작이라 URL이 잘린다. `/$()/`로 바꿔 넣는다.
ESCAPED_BASE_URL=$(printf '%s' "$BASE_URL" | sed 's#//#/$()/#g')

cat > "$CONFIG_DIR/Secret.xcconfig" <<XCCONFIG
BASE_URL = $ESCAPED_BASE_URL
KAKAO_NATIVE_APP_KEY = $KAKAO_NATIVE_APP_KEY
AMPLITUDE_API_KEY = $AMPLITUDE_API_KEY
XCCONFIG

# 로컬은 match 프로파일로 Manual 서명하지만, Xcode Cloud는 클라우드 서명을 쓰므로 Automatic으로 둔다.
# 아카이브가 개발 인증서로 서명되면 업로드가 거부되므로 아이덴티티는 Apple Distribution으로 고정한다.
for config in Debug Release; do
    cat > "$CONFIG_DIR/$config.xcconfig" <<XCCONFIG
#include "Secret.xcconfig"

DEVELOPMENT_TEAM = UKY6HK6U6Y
CODE_SIGN_STYLE = Automatic
CODE_SIGN_IDENTITY = Apple Distribution
APS_ENVIRONMENT = production
XCCONFIG
done

echo "=== [ci_post_clone] GoogleService-Info.plist 생성 ==="
printf '%s' "$GOOGLE_SERVICE_INFO_PLIST_BASE64" | base64 --decode > Projects/ChungBazi/Resources/GoogleService-Info.plist
plutil -lint Projects/ChungBazi/Resources/GoogleService-Info.plist

echo "=== [ci_post_clone] 워크스페이스 생성 (버전 $TUIST_MARKETING_VERSION / 빌드 번호 ${CI_BUILD_NUMBER:-1}) ==="
TUIST_BUILD_NUMBER="${CI_BUILD_NUMBER:-1}" mise exec -- tuist generate --no-open

echo "=== [ci_post_clone] 완료 ==="
