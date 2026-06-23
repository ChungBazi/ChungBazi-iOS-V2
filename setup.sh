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

# 2. xcconfig 파일 생성 (없으면 템플릿에서 복사)
CONFIG_DIR="Projects/ChungBazi/Configurations"
for ENV in Debug Release; do
  if [ ! -f "$CONFIG_DIR/$ENV.xcconfig" ]; then
    echo "[xcconfig] $ENV.xcconfig not found. Creating from template..."
    cp "$CONFIG_DIR/$ENV.xcconfig.template" "$CONFIG_DIR/$ENV.xcconfig"
    echo "[xcconfig] $CONFIG_DIR/$ENV.xcconfig created. 값을 채운 후 빌드를 진행하세요."
  fi
done

# 2. .mise.toml에 정의된 Tuist 버전 설치
echo "[tuist] Installing pinned version from .mise.toml..."
mise install

TUIST_VERSION=$(mise exec -- tuist version)
echo "[tuist] Active version: $TUIST_VERSION"

# 3. SPM 패키지 설치
echo "[tuist] Running 'tuist install'..."
mise exec -- tuist install

echo ""
echo "Setup complete!"
echo "Run: mise exec -- tuist generate"
