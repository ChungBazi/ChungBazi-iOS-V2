#!/bin/bash
set -e

echo "=== ChungBazi iOS V2 - Dev Environment Setup ==="

# 1. mise 설치 확인
if ! command -v mise &> /dev/null; then
  echo "[mise] Installing mise..."
  curl https://mise.run | sh

  SHELL_NAME=$(basename "$SHELL")
  case "$SHELL_NAME" in
    zsh)
      echo 'eval "$(~/.local/bin/mise activate zsh)"' >> ~/.zshrc
      eval "$(~/.local/bin/mise activate zsh)"
      ;;
    bash)
      echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc
      eval "$(~/.local/bin/mise activate bash)"
      ;;
    *)
      echo "[mise] Please manually add mise activation to your shell profile."
      ;;
  esac
else
  echo "[mise] Already installed: $(mise --version)"
fi

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
