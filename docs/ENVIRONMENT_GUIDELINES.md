# Environment Guidelines

ChungBazi iOS의 개발·운영 환경 구성입니다. **빌드 구성이 곧 환경이고, 환경마다 별도의 앱**으로 설치됩니다. 서버 주소를 손으로 바꿔가며 빌드하지 않습니다.

---

## 핵심 원칙

- **Debug = 청바지 Dev, Release = 청바지.** 두 앱은 번들 ID가 달라 한 기기에 함께 설치되고, Keychain과 UserDefaults가 iOS 수준에서 격리됩니다.
- **서버 주소와 키는 구성별 xcconfig에 고정합니다.** 다른 서버를 보려고 `BASE_URL`을 바꾸지 않습니다.
- **세션은 서버 호스트에 묶입니다.** 저장된 호스트와 현재 호스트가 다르면 첫 요청 전에 토큰을 폐기하고 재로그인으로 보냅니다.

---

## 환경 구성

| | Debug | Release |
|---|---|---|
| 앱 이름 | 청바지 Dev | 청바지 |
| 번들 ID | `com.yeonho.chungbazi.dev` | `com.yeonho.chungbazi` |
| 서버 | dev | 운영 |
| 딥링크 스킴 | `chungbazi-dev://` | `chungbazi://` |
| 푸시(APNs) | development | production |
| 서명 | match Development | match AppStore (로컬), 클라우드 서명 (Xcode Cloud) |
| 실행 방법 | Xcode Run | TestFlight, App Store |

### 값이 정의되는 곳

| 값 | 위치 | 커밋 여부 |
|---|---|---|
| 번들 ID 접미사, 앱 이름, 딥링크 스킴 | `Projects/ChungBazi/Project.swift`의 구성별 settings | 커밋 |
| `BASE_URL`, `KAKAO_NATIVE_APP_KEY`, `AMPLITUDE_API_KEY`, 서명 설정 | `Projects/ChungBazi/Configurations/{Debug,Release}.xcconfig` | gitignore |
| Firebase 설정 | `Projects/ChungBazi/Configurations/Firebase/{Debug,Release}/GoogleService-Info.plist` | gitignore |

`GoogleService-Info.plist`는 빌드 단계(`Copy GoogleService-Info.plist`)에서 현재 구성의 파일이 앱 번들에 복사됩니다. `Resources/`에는 두지 않습니다.

---

## 로컬 세팅

`./setup.sh`가 xcconfig 템플릿과 Firebase 폴더를 만듭니다. 이후 값을 채웁니다.

```
Projects/ChungBazi/Configurations/
├── Debug.xcconfig        # dev 서버 주소, dev 키, match Development com.yeonho.chungbazi.dev
├── Release.xcconfig      # 운영 서버 주소, 운영 키, match AppStore com.yeonho.chungbazi
└── Firebase/
    ├── Debug/GoogleService-Info.plist      # dev 번들 ID로 등록한 Firebase 앱
    └── Release/GoogleService-Info.plist    # 운영 번들 ID로 등록한 Firebase 앱
```

xcconfig에서 `//`는 주석이므로 주소는 `https:/$()/host/path` 형태로 씁니다.

프로파일 지정은 `PROVISIONING_PROFILE_SPECIFIER[sdk=iphoneos*]`로 실기기 빌드에만 적용합니다. 시뮬레이터는 프로파일 없이 실행됩니다.

인증서와 프로파일은 fastlane match로 받습니다.

```sh
fastlane match_development_readonly   # Dev 앱 개발용
fastlane match_appstore_readonly      # 운영 앱 배포용
```

---

## 새 팀원 온보딩

이 Apple Developer 계정은 개인(Individual) 계정이라 팀원을 초대할 수 없습니다. 서명 자산은 계정 소유자가 fastlane match로 발급하고, 팀원은 읽기 전용으로 받아 씁니다.

**계정 소유자가 해줄 것**

1. `ChungBazi-iOS-V2`, `ChungBazi-Certificates` 저장소 접근 권한 부여
2. 안전한 경로(비밀번호 관리자 등)로 전달: match 암호, `Debug.xcconfig`에 넣을 값(dev 서버 주소, dev 키), `Firebase/Debug/GoogleService-Info.plist`
3. 팀원의 기기 UDID를 Apple Developer의 Devices에 등록한 뒤 `fastlane match_development`를 `force_for_new_devices` 옵션으로 다시 실행해 프로파일 갱신

운영 값(`Release.xcconfig`, 운영 plist, App Store Connect API 키)은 배포 담당자만 가집니다. 팀원은 Debug만으로 개발할 수 있습니다.

**팀원이 할 것**

```sh
./setup.sh                               # Tuist 설치, xcconfig 템플릿 생성
# Debug.xcconfig 값 채우기, Firebase/Debug/에 plist 넣기
fastlane match_development_readonly      # 개발 인증서·프로파일 설치 (match 암호 필요)
mise exec -- tuist generate
```

- 시뮬레이터는 인증서 없이 바로 실행됩니다. 실기기는 3번(기기 등록) 이후 가능합니다.
- `Release.xcconfig`는 템플릿 그대로 두어도 Debug 개발에는 지장이 없습니다. `Firebase/Release/`에는 Debug용 plist를 복사해 두면 Release 구성 빌드가 필요할 때 막히지 않습니다.
- 브랜치와 PR 규칙은 `GIT_FLOW_GUIDELINES.md`를 따릅니다. 릴리즈 브랜치와 태그는 배포 담당자가 만듭니다.

---

## Dev 앱 최초 등록

Dev 번들 ID(`com.yeonho.chungbazi.dev`)를 외부 서비스에 한 번 등록합니다.

| 대상 | 작업 |
|---|---|
| Apple Developer | App ID 등록 (Push Notifications, Sign in with Apple 활성화) → `fastlane match_development`로 프로파일 발급 |
| 카카오 | dev용 앱을 만들거나 번들 ID를 추가하고, 그 네이티브 앱 키를 `Debug.xcconfig`에 넣습니다. 운영과 같은 키를 쓰면 `kakao{키}://` 스킴이 두 앱에서 겹쳐 로그인 복귀가 엉킵니다 |
| Firebase | dev 번들 ID로 iOS 앱 추가 → plist를 `Firebase/Debug/`에 저장 → APNs 인증 키 등록 |
| 백엔드 | dev 서버의 `apple.audience`를 dev 번들 ID로 설정 (Apple 로그인 토큰의 `aud`가 번들 ID입니다) |

---

## 운영 서버에서 확인하기

Release 구성은 App Store 배포용으로 서명되어 실기기에 직접 설치할 수 없습니다.

| 방법 | 시점 | 한계 |
|---|---|---|
| 시뮬레이터에서 Release 구성 실행 | 릴리즈 태그 전 | 푸시 알림 확인 불가 |
| TestFlight 빌드 | main 머지 후 (`GIT_FLOW_GUIDELINES.md` 참고) | 문제가 나오면 hotfix로 다음 버전 |

새 API를 쓰는 버전은 **백엔드가 운영 서버에 배포한 뒤** 릴리즈 브랜치를 땁니다. Release 빌드는 운영 서버만 봅니다.

---

## 세션과 서버 호스트

앱 시작 시 `SessionHostGuard`가 현재 `BASE_URL`의 호스트를 저장된 호스트와 비교합니다.

| 상태 | 동작 |
|---|---|
| 저장된 호스트 없음 (기존 설치) | 세션 유지, 현재 호스트 기록 |
| 같은 호스트 | 세션 유지 |
| 다른 호스트 | 토큰·세션 마커·세션 상태 삭제 → 재로그인 |

두 앱이 번들 ID로 격리되어 있으므로 평소에는 발동하지 않습니다. 같은 앱의 서버 주소가 바뀐 경우를 막는 안전장치입니다. 서버도 JWT의 `issuer`/`audience`로 다른 환경의 토큰을 거부합니다.

---

## 문제 해결

| 상황 | 대응 |
|---|---|
| 빌드가 "GoogleService-Info.plist 가 없습니다"로 실패 | `Configurations/Firebase/{구성}/`에 plist를 넣습니다 |
| Dev 앱에서 Apple 로그인만 실패 | dev 서버의 `apple.audience`가 dev 번들 ID인지 확인합니다 |
| Dev 앱에서 카카오 로그인 후 스토어 앱이 열림 | 두 앱이 같은 카카오 키를 쓰고 있습니다. `Debug.xcconfig`의 키를 dev용으로 바꿉니다 |
| 실기기 Debug 빌드가 서명 오류로 실패 | dev 번들 ID의 프로파일이 없습니다. `fastlane match_development_readonly`를 실행합니다 |
| "doesn't include signing certificate" 오류 | 키체인에 개발 인증서가 여러 개라 Xcode가 프로파일에 없는 것을 골랐습니다. `Debug.xcconfig`의 `CODE_SIGN_IDENTITY`를 match 인증서의 전체 이름으로 지정합니다 (`security find-identity -p codesigning -v`로 확인) |
| Dev 앱에 푸시가 오지 않음 | Firebase의 dev iOS 앱에 APNs 키가 등록됐는지 확인합니다 |
