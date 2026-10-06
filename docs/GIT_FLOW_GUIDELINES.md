# Git Flow Guidelines

ChungBazi iOS의 브랜치 전략과 배포 절차입니다. [git-flow](https://nvie.com/posts/a-successful-git-branching-model/)를 기반으로 하며, 릴리즈할 때 사람이 정하는 것은 **버전 숫자 하나**뿐입니다. 마케팅 버전, 빌드 번호, 태그, 백머지는 자동으로 처리됩니다.

---

## 핵심 원칙

- **버전은 브랜치명으로 선언합니다.** `release/2.1.0`을 만들면 그 릴리즈의 버전은 `2.1.0`입니다. `Project.swift`의 버전 숫자는 고치지 않습니다.
- **태그는 직접 찍지 않습니다.** main에 머지되면 GitHub Actions가 찍습니다.
- **Xcode Cloud는 태그에서만 돕니다.** 릴리즈당 1회입니다.
- **main으로 가는 PR과 백머지 PR은 `Create a merge commit`으로 머지합니다.** squash하면 main과 develop의 히스토리가 갈라져 다음 릴리즈마다 충돌합니다.

---

## 브랜치 구조

| 브랜치 | 역할 | 분기 기준 | 머지 대상 |
|---|---|---|---|
| `main` | 스토어에 나간 코드. 릴리즈·핫픽스 PR로만 갱신 | — | — |
| `develop` | 개발 기반. GitHub 기본 브랜치 | — | — |
| `feature/#이슈번호` 등 | 일반 작업 (`bugfix/`, `refactor/`, `design/`, `setting/` …) | `develop` | `develop` |
| `release/버전` | 릴리즈 선언과 마무리 수정 | `develop` | `main` |
| `hotfix/버전` | 출시된 버전의 긴급 수정 | `main` | `main` |

버전과 태그는 prefix 없이 `2.1.0` 형태로 씁니다. `v2.1.0`은 쓰지 않습니다.

---

## 최초 1회 로컬 세팅

```sh
brew install git-flow
```

클론한 레포 루트에서 아래를 실행합니다. git-flow 설정은 `.git/config`에만 저장되므로 클론마다 한 번씩 필요합니다.

```sh
git config gitflow.branch.master main
git config gitflow.branch.develop develop
git config gitflow.prefix.feature feature/
git config gitflow.prefix.release release/
git config gitflow.prefix.hotfix hotfix/
git config gitflow.prefix.support support/
git config gitflow.prefix.versiontag ""
```

`git flow ... finish` 명령은 로컬에서 직접 머지하고 태그를 찍으므로 **사용하지 않습니다.** 머지는 항상 PR로 합니다.

---

## 작업 흐름

### 일반 작업

1. 이슈를 만들고 `develop`에서 `타입/#이슈번호` 브랜치를 땁니다.
2. 작업 후 `develop` 타겟으로 PR을 엽니다.

### 릴리즈

```sh
git checkout develop && git pull
git flow release start 2.1.0        # develop에서 release/2.1.0 분기
git push -u origin release/2.1.0
```

1. 마무리 수정이 있으면 release 브랜치에 커밋합니다.
2. **로컬 기기 빌드로 검증합니다.** TestFlight 빌드는 main 머지 이후에만 만들어지므로 이 단계가 마지막 검증입니다.
3. `main` 타겟으로 PR을 열고 **Create a merge commit**으로 머지합니다.
4. 자동으로 진행되는 일을 기다립니다 ([자동화](#자동화) 참고).
5. TestFlight에 빌드가 올라오면 App Store Connect에서 심사에 제출합니다.
6. 자동 생성된 `main → develop` 백머지 PR을 **Create a merge commit**으로 머지합니다.

버전 숫자는 다음 기준으로 정합니다.

| 변경 | 올리는 자리 | 예시 |
|---|---|---|
| 호환되지 않는 큰 개편 | major | 2.1.0 → 3.0.0 |
| 기능 추가·개선 | minor | 2.1.0 → 2.2.0 |
| 버그 수정만 | patch | 2.1.0 → 2.1.1 |

### 핫픽스

핫픽스는 **이미 스토어에 나간 버전을, develop의 미출시 작업을 건드리지 않고 고쳐서 다시 내보내는 통로**입니다.

```sh
git checkout main && git pull
git flow hotfix start 2.1.1         # main에서 hotfix/2.1.1 분기
git push -u origin hotfix/2.1.1
```

이후 절차는 릴리즈의 2~6번과 같습니다. 백머지 PR을 머지해야 수정이 develop에도 들어가 다음 릴리즈에서 같은 버그가 되살아나지 않습니다.

**핫픽스를 쓰는 경우**

- 스토어 버전에서 다음 정기 릴리즈까지 기다릴 수 없는 문제가 나왔을 때
- main 머지 후 올라온 TestFlight 빌드에서 버그가 나왔을 때
- 심사 리젝으로 코드 수정이 필요할 때

**핫픽스를 쓰지 않는 경우**

- 급하지 않은 버그: `bugfix/#이슈번호 → develop`에 넣고 다음 릴리즈에 싣습니다.
- develop에 직전 릴리즈 이후 머지된 것이 없거나 전부 출시해도 될 때: develop에서 고치고 `release/2.1.1`로 올려도 됩니다.
- Xcode Cloud 빌드가 스크립트·secret 문제로 실패했을 때: 원인을 고친 뒤 같은 태그로 재실행합니다.

---

## 자동화

`release/*` 또는 `hotfix/*` 브랜치의 PR이 main에 머지되면 아래가 순서대로 실행됩니다.

| 자동화 | 하는 일 |
|---|---|
| GitHub Actions `Release` (`.github/workflows/release.yml`) | 브랜치명의 버전으로 머지 커밋에 태그 생성 → GitHub Release와 릴리즈 노트 생성 → `main → develop` 백머지 PR 생성 |
| Xcode Cloud `Deploy` | 태그를 감지해 아카이브 → TestFlight 업로드 |

### 버전과 빌드 번호

| 값 | 출처 | 주입 경로 |
|---|---|---|
| 마케팅 버전 (`CFBundleShortVersionString`) | 태그명 (`CI_TAG`) | `ci_post_clone.sh` → `TUIST_MARKETING_VERSION` → `Project.swift` |
| 빌드 번호 (`CFBundleVersion`) | Xcode Cloud 빌드 번호 (`CI_BUILD_NUMBER`) | `ci_post_clone.sh` → `TUIST_BUILD_NUMBER` → `Project.swift` |

로컬 빌드는 `Project.swift`의 기본값을 씁니다. 이 기본값은 표시용이라 릴리즈마다 갱신하지 않습니다.

---

## Xcode Cloud 설정

워크플로우는 App Store Connect(또는 Xcode)에서 직접 만듭니다. 저장소에는 `ci_scripts/ci_post_clone.sh`만 있습니다.

### `Deploy` 워크플로우

| 항목 | 값 |
|---|---|
| 시작 조건 | Tag Changes (모든 태그) |
| 동작 | Archive — 스킴 `ChungBazi`, 플랫폼 iOS |
| 배포 | TestFlight (Internal Testing) |

브랜치 변경이나 PR을 시작 조건으로 추가하지 않습니다. 컴퓨팅 시간 한도를 다른 프로젝트와 나눠 쓰기 때문입니다.

### 환경 변수

모두 **Secret**으로 등록합니다. 하나라도 비어 있으면 `ci_post_clone.sh`가 빌드 전에 실패합니다.

| 이름 | 값 |
|---|---|
| `BASE_URL` | 운영 서버 주소. `https://…` 그대로 넣습니다 (xcconfig 이스케이프는 스크립트가 처리) |
| `KAKAO_NATIVE_APP_KEY` | 카카오 네이티브 앱 키 |
| `AMPLITUDE_API_KEY` | Amplitude API 키 |
| `GOOGLE_SERVICE_INFO_PLIST_BASE64` | 운영용 `GoogleService-Info.plist`를 base64로 인코딩한 값 |

```sh
base64 -i Projects/ChungBazi/Resources/GoogleService-Info.plist | pbcopy
```

### 빌드 번호

App Store Connect는 같은 버전에서 이전 업로드보다 큰 빌드 번호를 요구합니다. 수동 업로드로 번호를 선점했다면 Xcode Cloud 설정의 **Next Build Number**를 그보다 크게 올립니다.

### 서명

로컬은 match 프로파일로 Manual 서명하지만(`setup.sh`, `fastlane`), Xcode Cloud는 클라우드 서명을 씁니다. `ci_post_clone.sh`가 CI 전용 xcconfig(Automatic, Apple Distribution)를 만들기 때문에 로컬 설정은 바꿀 필요가 없습니다.

---

## 문제 해결

| 상황 | 대응 |
|---|---|
| Xcode Cloud 빌드가 스크립트·secret 문제로 실패 | 원인을 고친 뒤 Xcode Cloud에서 같은 태그로 재실행합니다 |
| Xcode Cloud 빌드가 "릴리즈 태그 없이 실행되었습니다"로 실패 | 브랜치를 골라 수동 실행한 경우입니다. 수동 실행·재실행은 항상 릴리즈 태그를 선택합니다 |
| 코드 문제로 빌드 실패, 또는 TestFlight에서 버그 발견 | `hotfix/다음 patch 버전`으로 새로 올립니다. 태그는 옮기거나 지우지 않습니다 |
| `Release` 액션이 "브랜치명에서 버전을 읽을 수 없습니다"로 실패 | 브랜치명이 `release/X.Y.Z` 형식이 아닙니다. 올바른 이름의 브랜치로 다시 올립니다 |
| `Release` 액션이 태그 생성에서 실패 | 같은 버전 태그가 이미 있습니다. 다음 버전으로 올립니다 |
| 백머지 PR에 충돌 | `main`을 `develop`에 로컬에서 머지해 충돌을 풀고 PR로 올립니다 |
| 태그는 생겼는데 Xcode Cloud가 시작되지 않음 | Xcode Cloud에서 해당 태그로 수동 실행합니다. 반복되면 `release.yml`의 토큰을 PAT로 교체합니다 |
| 기능 PR을 실수로 main에 머지 | `Release` 액션은 `release/`·`hotfix/` 브랜치만 처리하므로 태그는 생기지 않습니다. main에서 revert합니다 |
