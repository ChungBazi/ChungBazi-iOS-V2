#!/bin/bash
set -e

echo "=== ChungBazi iOS V2 - Dev Environment Setup ==="

# 1. mise 설치 확인
if ! command -v mise &> /dev/null; then
  echo "[mise] Installing mise..."

  if [ -z "${MISE_INSTALLER_SHA256}" ]; then
    echo "[mise] ERROR: MISE_INSTALLER_SHA256가 설정되지 않았습니다."
    echo "       mise 공식 릴리즈에서 SHA256을 확인 후 환경변수로 설정해주세요."
    exit 1
  fi

  INSTALLER_URL="https://mise.run"
  TMP_SCRIPT="$(mktemp)"
  curl --fail --silent --show-error --location "$INSTALLER_URL" -o "$TMP_SCRIPT"
  echo "${MISE_INSTALLER_SHA256}  $TMP_SCRIPT" | shasum -a 256 -c -
  sh "$TMP_SCRIPT"
  rm -f "$TMP_SCRIPT"

  SHELL_NAME=$(basename "$SHELL")
  case "$SHELL_NAME" in
    zsh)
      echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
      eval "$(mise activate zsh)"
      ;;
    bash)
      echo 'eval "$(mise activate bash)"' >> ~/.bashrc
      eval "$(mise activate bash)"
      ;;
    *)
      echo "[mise] Please manually add mise activation to your shell profile."
      ;;
  esac
else
  echo "[mise] Already installed: $(mise --version)"
fi

# 2. xcconfig 파일 생성 (없으면 기본값으로 생성)
#    Debug = 청바지 Dev(dev 서버), Release = 청바지(운영 서버). 서버 주소와 키는 구성별로 따로 채운다.
CONFIG_DIR="Projects/ChungBazi/Configurations"
mkdir -p "$CONFIG_DIR"

create_xcconfig() {
  local ENV="$1"
  local PROVISIONING_PROFILE="$2"
  local CODE_SIGN_IDENTITY="$3"
  local APS_ENVIRONMENT="$4"
  cat > "$CONFIG_DIR/$ENV.xcconfig" <<EOF
DEVELOPMENT_TEAM = UKY6HK6U6Y
CODE_SIGN_STYLE = Manual
PROVISIONING_PROFILE_SPECIFIER[sdk=iphoneos*] = $PROVISIONING_PROFILE
CODE_SIGN_IDENTITY = $CODE_SIGN_IDENTITY
APS_ENVIRONMENT = $APS_ENVIRONMENT
BASE_URL =
KAKAO_NATIVE_APP_KEY =
AMPLITUDE_API_KEY =
EOF
  echo "[xcconfig] $CONFIG_DIR/$ENV.xcconfig created. 값을 채운 후 빌드를 진행하세요."
}

if [ ! -f "$CONFIG_DIR/Debug.xcconfig" ]; then
  echo "[xcconfig] Debug.xcconfig not found. Creating with defaults..."
  create_xcconfig "Debug" "match Development com.yeonho.chungbazi.dev" "Apple Development" "development"
fi

if [ ! -f "$CONFIG_DIR/Release.xcconfig" ]; then
  echo "[xcconfig] Release.xcconfig not found. Creating with defaults..."
  create_xcconfig "Release" "match AppStore com.yeonho.chungbazi" "Apple Distribution" "production"
fi

# GoogleService-Info.plist는 구성별 폴더에 둔다 (빌드 시 구성에 맞는 파일이 앱에 복사됨)
for ENV in Debug Release; do
  FIREBASE_DIR="$CONFIG_DIR/Firebase/$ENV"
  mkdir -p "$FIREBASE_DIR"
done
if [ ! -f "$CONFIG_DIR/Firebase/Debug/GoogleService-Info.plist" ]; then
  echo "[firebase] $CONFIG_DIR/Firebase/Debug/GoogleService-Info.plist 가 없습니다. dev용 plist를 받아 넣어주세요."
fi
if [ ! -f "$CONFIG_DIR/Firebase/Release/GoogleService-Info.plist" ]; then
  echo "[firebase] Release용 plist는 Release 빌드가 필요할 때만 운영용으로 받아 넣습니다. (Debug용을 복사하지 마세요)"
fi

# 3. .mise.toml에 정의된 Tuist 버전 설치
echo "[tuist] Installing pinned version from .mise.toml..."
mise install

TUIST_VERSION=$(mise exec -- tuist version)
echo "[tuist] Active version: $TUIST_VERSION"

# 4. SPM 패키지 설치
echo "[tuist] Running 'tuist install'..."
mise exec -- tuist install

echo ""
echo "Setup complete!"
echo "Run: mise exec -- tuist generate"
