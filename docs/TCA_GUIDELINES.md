# TCA Guidelines

The Composable Architecture(이하 TCA)를 사용하는 **iOS SwiftUI 프로젝트(ChungBazi)**의 컨벤션입니다.
이 문서는 **개발자가 Feature를 작성할 때의 기준**이자, **AI 에이전트가 PR을 리뷰할 때의 기준**입니다.

대상 모듈: `BaziPresentation`
의존성 선언: `Tuist/Package.swift`
관련 문서: [CODING_GUIDELINES.md](./CODING_GUIDELINES.md)

> **이 문서에 대하여**
> - `BaziPresentation`(Feature 구현) / `BaziDomain`(순수 규칙) / `BaziData`(Repository 구현, `BaziNetwork`+`BaziStorage`에 의존) / App 타겟 `ChungBazi`(Composition Root) 구조를 기준으로 작성했습니다.
> - 전 모듈이 **Swift 6 언어 모드**(`SWIFT_VERSION = 6.0`, strict concurrency)로 설정되어 있습니다. 5.4절의 `Result { try await ... }` 축약을 사용합니다.
> - `@Reducer enum`(Path/Destination) 선언 뒤에는 **반드시 `extension X.State: Equatable {}`을 직접 추가**해야 합니다. 생성된 `State`가 기본적으로 `Equatable`을 준수하지 않아 부모 `State: Equatable`이 깨집니다 — 7.5절 참고 (TCA 1.26.0 매크로 소스로 직접 확인). `@Reducer(state: .equatable)` 매크로 인자 방식은 deprecated이니 쓰지 않습니다.
> - `SWIFT_DEFAULT_ACTOR_ISOLATION`을 `nonisolated`로 명시 고정해뒀습니다(`Project+Templates.swift`). 위 이슈의 원인은 아니었지만 Swift 6 + TCA 조합에서 일반적으로 안전한 기본값이라 유지합니다.
> - `tuist scaffold feature --name X` 템플릿이 `Tuist/Templates/feature/`에 준비되어 있습니다 ("새 Feature 시작하기" 절 참고).

> **이 문서를 읽는 사람에게**
> TCA를 처음 사용한다면 [0. 시작하기 전에 — 마인드모델](#0-시작하기-전에--마인드모델)부터 순서대로 읽으세요.
> 이미 익숙하다면 [12. 리뷰 체크리스트](#12-리뷰-체크리스트-ai-에이전트용)로 바로 가도 됩니다.
> 본문 각 절에는 *언제 이걸 쓰는가 → 왜 이렇게 쓰는가 → 어떻게 쓰는가* 순서로 정리돼 있습니다.

---

## 왜 TCA인가

이 절은 "TCA를 어떻게 쓰는가"가 아니라 **TCA의 핵심 이점이 무엇이고, 그게 왜 ChungBazi라는 앱과 맞는가**를 남겨두는 절입니다. 규칙이 번거롭게 느껴질 때, 혹은 새로 합류한 사람이 "왜 굳이 이렇게까지"라고 물을 때 참고하세요.

### TCA의 핵심 이점 4가지

1. **단방향 흐름 = 상태 변화의 완전한 역추적성**
   모든 State 변화가 "어떤 Action이 들어와서" 일어났는지 항상 명확합니다. `@Observable` + Coordinator 방식은 여러 곳(View, Coordinator 메서드, Effect 클로저)에서 State를 직접 건드릴 수 있어서, 버그가 나면 "어디서 이 값이 바뀌었는지" 역추적해야 합니다. TCA는 변경 지점이 Reducer 하나로 강제되어 이 문제가 구조적으로 없어집니다.

2. **Reducer가 순수 함수 → 네트워크 없이 비즈니스 로직 전체를 테스트 가능**
   `.run`/`@Dependency`로 부수효과를 다 빼내면, "이 Action이 들어오면 State가 이렇게 변해야 한다"를 `TestStore`로 검증할 수 있습니다.

3. **합성 가능성(Composability)** — 작은 Feature를 조립해 큰 화면을 만듭니다.

4. **네비게이션이 State의 일부 — 상태 기반 복원이 가능**
   `Destination`/`StackState`는 "지금 어떤 화면이 떠 있는지"를 State 값으로 취급합니다. 그래서 화면 전환이 곧 State 스냅샷이 되고, 이 스냅샷을 저장/복원하면 딥링크나 재실행 후 화면 복원이 자연스럽게 됩니다.

### 왜 이게 ChungBazi 화면 구조와 정확히 맞는가

일반론이 아니라 지금 이미 존재하는 코드에서 확인되는 겹침입니다.

- **`HomeRoute`를 보면 홈 화면 자체가 이미 여러 독립 섹션의 합성입니다** — `categoryPolicyList`, `popularPolicyList`, `deadlinePolicyList`, `newPolicyList`가 각자 자기 로딩 상태·자기 데이터를 가진 섹션들입니다. Coordinator 방식이면 이 4개 섹션의 로딩/에러 상태를 결국 홈 화면의 `@State` 하나에 다 몰아넣게 되는데, TCA면 각 섹션을 독립된 자식 Feature로 만들어 `forEach`나 개별 `Scope`로 조립하면 됩니다. "합성 가능성"이 추상적 장점이 아니라 지금 화면 목록에 그대로 필요한 이유입니다.
- **`AppCoordinator`의 `calendarSelectedDate`가 이미 "상태 기반 네비게이션 복원"을 요구하고 있었습니다** — "캘린더 sheet → 메모/정책 상세 → 재오픈"이라는 주석이 코드에 이미 있었습니다. 이건 정확히 TCA의 `Destination` State가 잘하는 일입니다: 지금 뭐가 떠 있는지가 State 값이니, 그 값을 저장했다가 복원하면 "재오픈" 요구사항이 특별한 코드 없이 풀립니다. 지금 Coordinator 방식은 이걸 위해 `calendarSelectedDate`라는 별도 변수를 수동으로 관리해야 했는데, TCA에서는 그게 그냥 `Destination.State`의 일부입니다.
- **정책 목록 화면은 대부분 커서 기반 무한스크롤입니다** — `HomeAPI.getPolicies(category:sort:cursor:size:)`, `PolicySearchAPI.search(...:cursor:size:)`처럼 정렬/필터는 서버가 처리하고 클라이언트는 커서를 들고 다음 페이지를 요청합니다. "다음 페이지 로딩 중에 또 스크롤하면 중복 요청되지 않는가", "정렬 옵션을 바꾸면 이전 목록 요청이 취소되고 새로 시작하는가" 같은 상태 전이를 Reducer 로직으로 빼면 실제 서버 없이도 `TestStore`로 검증할 수 있습니다.
- **`PolicySearch` 화면은 디바운스·취소가 필요한 전형적 사례입니다** — 검색어를 칠 때마다 이전 요청을 취소하고 새 요청만 살아있어야 하는데, 이건 TCA의 `cancellable(id:cancelInFlight:)`이 정확히 풀도록 설계된 문제입니다.
- **`AuthRoot`(login → nicknameSetup → onboarding)는 순차적 상태 머신입니다** — enum 기반 State + `ifCaseLet` 합성이 정확히 이런 "여러 단계 중 하나"를 표현하기 위한 도구입니다.

정리하면: TCA의 이점(합성성, 테스트 가능성, 상태 기반 네비게이션)이 추상적으로 좋다는 게 아니라, 지금 존재하는 `HomeRoute`의 섹션 구조, `calendarSelectedDate`의 재오픈 요구사항, `PolicySearch`의 디바운스 필요성, `AuthRoot`의 단계별 흐름 하나하나가 TCA가 풀도록 설계된 문제와 그대로 겹칩니다.

### TCA가 실제로 잘 푸는 문제 (환경·코드와 무관한 본질)

1. **비즈니스 로직을 UI와 완전히 분리해서, 그 로직만 독립적으로 검증할 수 있게 한다.** Reducer가 순수 함수라 "이런 입력이 오면 이런 결과가 나와야 한다"를 화면을 띄우지 않고도 증명할 수 있습니다.
2. **여러 개의 독립적인 부분 화면을 안전하게 하나로 합칠 수 있다.** 각 부분이 자기 상태를 스스로 갖고, 서로 직접 건드리지 않으면서도 하나의 화면으로 조립됩니다.
3. **비동기 데이터의 상태(로딩/성공/실패/빈 값)를 코드 레벨에서 빠뜨릴 수 없게 강제한다.**
4. **"지금 어떤 화면에 있는지" 자체를 데이터로 다뤄서, 여러 진입 경로가 같은 화면으로 수렴하는 상황을 예측 가능하게 만든다.**

### 왜 ChungBazi라는 앱의 본질과 맞는가 (프로젝트 상황과 무관하게 성립)

- **필터링/정렬 자체는 서버가 수행합니다** (`PolicySearchAPI`, `HomeAPI`가 `category`/`sort`/`cursor`를 쿼리 파라미터로 받음). 클라이언트의 책임은 "사용자가 고른 카테고리·정렬 옵션을 정확히 파라미터로 변환해서 보내는 것"과 **커서 기반 무한스크롤 상태**(다음 페이지 요청 시점, 로딩 중/끝에 도달함 판단, 중복 요청 방지)를 관리하는 것입니다. 이건 정렬 옵션이 바뀔 때 이전 요청을 취소하고 새 요청만 살려야 한다는 점에서 5.2절의 `cancellable(id:cancelInFlight:)`이 풀도록 설계된 문제와 정확히 같은 모양이고, "로딩 중 / 다음 페이지 없음 / 에러"를 명시적으로 구분해야 한다는 점에서 2.4절의 `LoadingState` 모델링이 필요한 지점입니다.
- **정책 추천 앱은 본질적으로 "여러 기준으로 나뉜 리스트들의 모음"입니다.** 카테고리별, 인기순, 마감임박순, 관심사 기반처럼 같은 원본 데이터를 여러 기준으로 잘라 동시에 보여주는 구조 자체가 이 앱의 본질이고, 이건 "독립된 부분을 안전하게 합성한다"는 TCA의 강점과 구조적으로 겹칩니다.
- **거의 모든 화면이 서버 데이터에 의존하는 정보성 앱입니다.** 캐시된 정적 데이터가 아니라 정책 정보를 계속 받아와야 하니, 로딩/실패/빈 결과를 빠짐없이 다루는 게 선택이 아니라 필수인데, 이게 TCA가 강제하는 부분과 정확히 맞습니다.
- **알림, 캘린더, 검색 결과 등 여러 경로에서 "같은 정책 상세 화면"으로 도달하는 구조입니다.** 진입 경로가 다양할수록 "지금 어떤 화면 상태인가"가 뒤엉키기 쉬운데, 이건 TCA가 네비게이션을 예측 가능한 데이터로 다루는 이유가 실질적으로 필요한 지점입니다.
- **정부 지원 서비스 특성상 사용자 온보딩이 단계형입니다.** 본인 정보 입력 → 관심 분야 설정처럼 순서가 있는 흐름은, 그 순서 자체를 코드가 잘못 표현하면 사용자가 중간에 이상한 상태에 갇히는 문제로 이어지는데, TCA는 이런 "여러 단계 중 정확히 하나"를 타입으로 강제해서 표현합니다.

결국 요약하면: **커서 기반 무한스크롤 상태 관리, 여러 리스트의 합성, 서버 의존적 화면, 다경로 진입이라는 이 앱의 본질적 특성 자체가 TCA가 잘 푸는 문제와 겹칩니다.** 이건 프로젝트 상황(타이밍, 팀 규모, 툴체인)과 무관하게 성립하는 이유입니다.

### 같이 인지하고 가는 트레이드오프

TCA 채택 자체가 공짜는 아닙니다. 실제로 확인된 비용:

- **의존성 트리** — TCA 하나를 추가하면 `swift-collections`, `swift-syntax`, `swift-perception`, `swift-dependencies`, `swift-navigation`, `swift-case-paths` 등 13개의 transitive 패키지가 딸려 옵니다.
- **Feature당 코드량/빌드 시간 증가** — State/Action/Reducer/View 4분할 구조는 동일 기능의 순정 SwiftUI보다 코드량이 늘어납니다.
- **`@Dependency`의 런타임 매직** — task-local 기반 암묵적 주입이라 escaping closure나 Sendable 관련해서 가끔 직관과 다르게 동작할 수 있습니다.

**완화책**: 7.3절의 판단 기준("행이 단순한 표시용 카드라면 Feature로 만들지 말고 plain SwiftUI View로 둔다")을 엄격하게 적용합니다. 모든 화면·모든 하위 컴포넌트를 Feature로 만들 필요는 없습니다 — State를 갖고 사용자 입력에 반응하며 테스트가 필요한 단위만 Feature로 승격시킵니다.

---

## 0. 시작하기 전에 — 마인드모델

TCA의 흐름은 단 네 가지 단어로 요약됩니다.

| 개념 | 한 줄 정의 | 비유 |
|---|---|---|
| **State** | 화면이 그릴 수 있는 모든 정보 | 사진(스냅샷) |
| **Action** | 화면에서 *일어난 일* | 사진을 바꾸는 사건 |
| **Reducer** | "이 사건이 일어나면 State를 어떻게 바꿀지" 규칙 | 사진 편집기 |
| **Store** | State와 Reducer를 묶어 View에 노출하는 런타임 | 사진 액자 |

흐름은 항상 **단방향**입니다.

```text
사용자 입력
    ↓
View가 Action을 store에 보냄  (store.send(.didTapAddButton))
    ↓
Reducer가 Action을 받아 State를 변경 / Effect 반환
    ↓
State 변경 → View가 자동으로 다시 그려짐
    ↓
(Effect가 끝나면 또 다른 Action을 보내 위 흐름을 반복)
```

처음 TCA를 만나면 "왜 이렇게 복잡하게 하지?" 싶을 수 있습니다. 하지만 이 단방향 흐름이 주는 보상은 큽니다.

- **모든 상태 변화의 원인을 추적 가능** — "어떤 Action이 들어와서 State가 이렇게 됐다"가 항상 명확.
- **테스트 가능성** — Reducer는 순수 함수이므로 `Action 입력 → State 출력`을 검증하면 끝.
- **합성 가능성** — 작은 Feature를 만들어 큰 Feature 안에 그대로 꽂아 넣을 수 있음.

이 문서의 모든 규칙은 위 세 가지 보상을 지키기 위해 존재합니다. 규칙이 헷갈릴 때마다 **"이 규칙이 위 세 가지 중 무엇을 지키는가?"** 를 떠올리면 됩니다.

---

## 핵심 원칙

1. **State는 값타입**이고, **변경은 오직 Reducer 안에서**만 이루어진다.
2. **Action은 "일어난 일"이지 "해야 할 일"이 아니다.** 명령형이 아닌 이벤트형으로 명명한다.
3. **Reducer는 순수 함수**다. 비동기 작업·외부 자원 접근은 전부 `Effect` 또는 `@Dependency`로 빼낸다.
4. **자식 Feature는 부모의 일부 가지**다. 자식 Store는 부모에서 `scope`로 내려준다.
5. **View는 표현(presentation)만** 한다. 비즈니스 로직·라우팅 분기·외부 호출은 Reducer가 책임진다.
6. **테스트는 `TestStore`로 한다.** Reducer는 Action 시퀀스로 검증한다.

---

## 새 Feature 시작하기

`Tuist/Templates/feature/`에 scaffold 템플릿이 준비되어 있습니다. 아래처럼 사용합니다.

```bash
tuist scaffold feature --name PolicyList
```

생성 결과:

```text
Projects/BaziPresentation/Sources/Features/PolicyList/
├── PolicyListFeature.swift   // @Reducer + State/Action/Delegate/Dependencies/Init/Body 골격
└── PolicyListView.swift      // Properties/Init/Body + Subviews + Preview
```

생성된 파일은 본 문서의 [12절 체크리스트](#12-리뷰-체크리스트-ai-에이전트용) 기본 항목(`@Reducer`, `@ObservableState`, exhaustive switch, `delegate(_)` Action, `.task` 패턴, MARK 섹션 구분 등)을 이미 통과한 상태입니다. 신규 Feature는 **반드시 scaffold로 시작**합니다.

> scaffold가 만들어 준 파일에서 출발해 *State 필드 추가 → Action 케이스 추가 → 각 case 본문 작성 → View 구현 → Test 작성* 순서로 살을 붙이면 됩니다.

---

## 1. 파일 구조

### 1.1 Feature 단위 디렉토리

하나의 Feature는 **하나의 디렉토리**로 묶고, 최소 `Feature.swift`와 `View.swift`를 함께 둡니다.

```text
BaziPresentation/Sources/Features/
├── AppFeature.swift                  // 루트 Reducer (AppPhase 전환 포함)
├── AppView.swift
├── Home/
│   ├── HomeFeature.swift             // 탭 루트 (StackState<Path.State> 보유)
│   └── HomeView.swift
├── PolicyDetail/
│   ├── PolicyDetailFeature.swift
│   ├── PolicyDetailView.swift
│   └── Components/                   // 이 화면에서만 쓰이는 보조 View
│       └── PolicyMetaSection.swift
```

> **왜 디렉토리로 묶는가?**
> Feature는 *Reducer + View + (필요 시) 보조 View*가 하나의 단위입니다. 디렉토리로 묶어두면 한 화면에 관련된 모든 파일을 한 번에 열고 닫을 수 있고, 다른 화면으로 옮길 때도 디렉토리째 옮기면 됩니다. 지금 `Coordinator/Routes/`가 도메인별(Home, Search, MyPolicy, Profile...)로 나뉜 것과 동일한 경계를 그대로 `Features/`에 적용합니다.

### 1.2 지금은 단일 모듈, 나중에 모듈 단위로 쪼갤 가능성은 열어둔다

지금은 `BaziPresentation` **모듈 하나**에 모든 Feature를 `Features/{도메인}/` 디렉토리로만 나눕니다. `BaziPresentation-Home`, `BaziPresentation-Search`처럼 기능마다 별도 Tuist 모듈(별도 `Project.swift`)로 쪼개는 것은 **지금 하지 않습니다.**

**지금 안 하는 이유**
- TCA의 Composition(`Scope`/`ifLet`/`forEach`)은 같은 모듈 안에서도 완전히 동작하므로 모듈 분리가 TCA 도입의 전제 조건이 아닙니다.
- 모듈 분리의 실익(빌드 시간 단축, 컴파일러가 강제하는 경계)은 코드량과 팀 규모가 커져야 체감됩니다. 아직 존재하지 않는 병목을 위해 미리 쪼개는 건 과설계입니다.
- 혼자 개발 중이라 모듈 분리의 핵심 이득(동시 작업 시 머지 충돌 방지)이 지금은 발생하지 않습니다.
- scaffold 템플릿도 아직 없는 상태에서 Feature 하나 추가할 때마다 새 `Project.swift`와 의존성 그래프를 손으로 관리하는 오버헤드가, 지금 단계에서는 개발 속도를 오히려 늦춥니다.

**재검토 신호** (아래 중 하나라도 해당하면 그때 모듈 분리를 다시 검토)
- `BaziPresentation`의 증분 빌드 시간이 체감될 정도로 느려질 때
- 팀원이 2~3명 이상으로 늘어 같은 모듈에서 동시 작업 충돌이 잦아질 때
- 특정 Feature가 여러 곳에서 재사용되며 "이 모듈은 다른 모듈을 몰라야 한다"는 컴파일러 강제가 필요해질 때

**나중에 쪼갤 때 마찰을 줄이려면 지금부터 지킬 것**
- 각 `Features/{도메인}/` 디렉토리는 **자기 완결적**으로 유지합니다. 다른 Feature의 State/타입을 직접 import하지 말고(10.7절 참고), 필요하면 부모를 통해 데이터를 전달하거나 `BaziDomain`의 공유 어휘만 사용합니다.
- Feature 간 통신은 항상 `delegate(_)` Action으로만 합니다(3.3절). 모듈이 갈라져도 delegate 표면만 유지하면 재배선이 쉽습니다.
- 이 두 규칙만 지키면, 나중에 `Features/Home/` 디렉토리를 통째로 새 Tuist 모듈로 옮기고 `Project.swift`만 추가하는 **기계적인 리팩터링**이 되지, 재설계가 되지 않습니다.

### 1.3 네이밍

| 대상 | 규칙 | 예시 |
|---|---|---|
| Reducer 타입 | `{도메인}Feature` | `PolicyListFeature` |
| Reducer 파일 | `{도메인}Feature.swift` | `PolicyListFeature.swift` |
| View 타입 | `{도메인}View` | `PolicyListView` |
| View 파일 | `{도메인}View.swift` | `PolicyListView.swift` |
| 자식 화면 enum 케이스 | 명사 (화면 이름) | `case detail(PolicyDetailFeature)` |

> Reducer 이름에 `ViewModel`, `Store`, `Reducer` 접미사는 붙이지 않습니다.
> Store는 런타임 인스턴스이지 타입이 아닙니다. (`StoreOf<PolicyListFeature>` 가 런타임 타입)

---

## 2. State

### 2.1 선언

State는 **화면이 한 순간에 그릴 수 있는 모든 정보**입니다. 다음 세 가지를 반드시 지킵니다.

- `@ObservableState`를 반드시 붙입니다. (`@Observable` 아님 — TCA 전용 매크로)
- `Equatable`을 채택합니다. (`TestStore`가 변경 전후를 비교할 때 사용)
- **모든 프로퍼티는 값타입**이어야 합니다. (`class`, `ObservableObject` 금지)

```swift
// ✅ Good
@Reducer
struct PolicyListFeature {

  @ObservableState
  struct State: Equatable {
    var policies: IdentifiedArrayOf<Policy> = []
    var isLoading = false
    var searchText = ""
    @Presents var destination: Destination.State?
  }
}

// ❌ Bad
struct State {                              // @ObservableState 없음
  var viewModel: SomeViewModel              // reference type
  var policies: [Policy]                    // IdentifiedArray 미사용
}
```

> **자주 하는 질문: "왜 class를 못 쓰나요?"**
> Reducer는 "Action이 들어오기 전 State"와 "Action이 처리된 후 State"를 비교해 테스트합니다. class(참조)는 변경하면 이전 스냅샷이 사라져 비교 불가입니다. struct(값)는 변경 시 새 인스턴스가 만들어지므로 이전/이후를 모두 보존할 수 있습니다.

### 2.2 컬렉션은 `IdentifiedArrayOf`

자식 Feature를 행으로 갖는 리스트는 **반드시** `IdentifiedArrayOf<Element>`를 씁니다.
ID 기반 접근·자식 Action 라우팅이 가능해야 하기 때문입니다.

```swift
// ✅ Good
var rows: IdentifiedArrayOf<PolicyRowFeature.State> = []

// ❌ Bad
var rows: [PolicyRowFeature.State] = []
```

> **왜?**
> 일반 `[Element]`는 인덱스(0, 1, 2)로만 접근합니다. 한 행을 지우거나 정렬을 바꾸면 인덱스가 어긋나 *"3번 행에 들어온 Action이 사실은 다른 행을 가리키는"* 사고가 납니다. `IdentifiedArrayOf`는 ID로 추적하므로 순서가 바뀌어도 Action이 정확한 자식에게 전달됩니다.

### 2.3 파생 데이터는 computed property

State에 **계산 가능한 값을 저장하지 않습니다.** 항상 computed로 노출합니다.

```swift
// ✅ Good
struct State: Equatable {
  var policies: IdentifiedArrayOf<Policy> = []
  var searchText = ""

  var filteredPolicies: IdentifiedArrayOf<Policy> {
    guard !searchText.isEmpty else { return policies }
    return policies.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
  }
}

// ❌ Bad — policies나 searchText가 바뀔 때마다 동기화 누락 위험
struct State: Equatable {
  var policies: IdentifiedArrayOf<Policy> = []
  var searchText = ""
  var filteredPolicies: IdentifiedArrayOf<Policy> = []  // ← 어디서 갱신?
}
```

> **판단 기준:** "이 값은 다른 State 값들로부터 *항상 계산할 수 있는가?*" 그렇다면 무조건 computed. 저장하는 순간 "갱신을 잊은 케이스"가 버그가 됩니다.

### 2.4 옵셔널 vs 빈 컬렉션 — "아직 안 옴"과 "비어 있음"을 구분

- "값이 아직 로드되지 않음" → `Optional` 또는 명시적 상태(enum)
- "값은 있지만 비어 있음" → 빈 컬렉션

```swift
// ✅ Good — 로딩 전과 빈 결과를 구분
enum LoadingState<Value: Equatable>: Equatable {
  case idle
  case loading
  case loaded(Value)
  case failed(String)
}

var policies: LoadingState<IdentifiedArrayOf<Policy>> = .idle
```

> **언제 LoadingState를 도입할까?**
> 화면이 "로딩 스피너 / 빈 상태 일러스트 / 결과 리스트 / 에러 메시지" 네 가지 모습을 모두 가져야 한다면 `LoadingState` 같은 enum이 정답입니다.
> 단순히 "데이터 있음/없음"만 보여주면 되는 화면이라면 `[Policy]`로 충분합니다.
> **모델링이 화면 분기를 정확히 표현해야 한다** — 이게 핵심입니다.

---

## 3. Action

### 3.1 네이밍 — "일어난 일"로 짓기

가장 자주 어기는 규칙입니다. Action은 **명령(verb)이 아니라 사건(event)**입니다.
[CODING_GUIDELINES §1](./CODING_GUIDELINES.md#1-네이밍)의 "이벤트 핸들러는 과거형" 규칙을 그대로 따릅니다.

| 분류 | 패턴 | 예시 |
|---|---|---|
| 사용자 입력 | `didTap{대상}`, `didChange{대상}` | `didTapAddButton`, `didChangeSearchText(String)` |
| 라이프사이클 | `{시점}` | `onAppear`, `task` |
| 비동기 응답 | `{대상}Response(Result)` | `policiesResponse(Result<[Policy], Error>)` |
| 내부 흐름 | `_{동사}` (언더스코어 prefix) | `_setLoading(Bool)` |
| 자식 위임 | `delegate({이벤트})` | `delegate(.policySaved(Policy))` |
| 자식/네비게이션 | `{자식이름}({자식.Action})` | `destination(PresentationAction<Destination.Action>)` |

```swift
// ✅ Good — 일어난 일
enum Action {
  case didTapAddButton
  case didChangeSearchText(String)
  case policiesResponse(Result<[Policy], Error>)
  case destination(PresentationAction<Destination.Action>)
  case delegate(Delegate)

  enum Delegate: Equatable {
    case policyDeleted(Policy.ID)
  }
}

// ❌ Bad — 명령형 / 동작 지시
enum Action {
  case loadPolicies
  case showAddSheet
  case handleResponse([Policy])
}
```

> **왜 명령형이 안 되는가?**
> `loadPolicies`라고 이름 붙이면 View가 "Reducer야, 정책을 불러와라"라고 *명령*하는 모양이 됩니다. 그럼 *어떻게* 불러올지를 View가 결정하는 셈입니다.
> `onAppear` / `didTapRefreshButton`이라고 쓰면 View는 "이런 사건이 일어났다"만 알리고, *어떻게 반응할지*는 Reducer가 결정합니다. 책임 경계가 또렷해집니다.

### 3.2 케이스 분류 (권장 그룹)

큰 Feature의 Action은 의미별로 nested enum 또는 주석으로 그룹화합니다. **Reducer 구조체 전체는 `// MARK: - X` 최상위 섹션으로, Action 내부는 `// MARK: X` 서브 섹션으로 구분**합니다 — [CODING_GUIDELINES §5](./CODING_GUIDELINES.md#5-파일-구성)의 MARK 규칙을 그대로 따른 것입니다.

```swift
@Reducer
struct PolicyListFeature {

  // MARK: - State

  @ObservableState
  struct State: Equatable {
    var policies: IdentifiedArrayOf<Policy> = []
  }

  // MARK: - Action

  enum Action {
    // MARK: View
    case onAppear
    case didTapAddButton
    case didTapRow(id: Policy.ID)

    // MARK: Internal
    case policiesResponse(Result<[Policy], Error>)

    // MARK: Child
    case destination(PresentationAction<Destination.Action>)

    // MARK: Delegate
    case delegate(Delegate)
  }

  // MARK: - Delegate

  enum Delegate: Equatable {
    case policyDeleted(Policy.ID)
  }

  // MARK: - Dependencies

  @Dependency(\.policyClient) var policyClient

  // MARK: - Init

  init() {}

  // MARK: - Body

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      // ...
    }
  }
}
```

> **그룹의 의미**
> - **View**: 사용자 입력 / 화면 라이프사이클. View가 보내는 Action.
> - **Internal**: Effect 응답·내부 흐름. Reducer가 자기 자신에게 보내는 Action.
> - **Child**: 자식 Feature가 보내는 Action을 부모로 끌어올린 통로.
> - **Delegate**: 부모에게 알리는 결과. (자세한 건 3.3절)

> **왜 `Delegate`를 `Action` 안에 중첩하지 않고 별도 최상위 섹션으로 빼는가?**
> `Delegate`는 자식이 부모에게 노출하는 공개 인터페이스라는 점에서 `State`/`Action`과 같은 급의 "이 Feature의 표면"입니다. `Action` 안에 파묻어두면 MARK로 접어놨을 때 눈에 안 띄기 쉬우므로, 독립된 `// MARK: - Delegate` 섹션으로 빼서 "이 Feature가 부모에게 뭘 알리는지"를 한눈에 보이게 합니다. `Dependencies`/`Init`도 같은 이유로 각자 섹션을 갖습니다 — Feature 하나를 열었을 때 State → Action → Delegate → Dependencies → Init → Body 순서로 읽으면 그 화면의 전체 계약을 위에서 아래로 파악할 수 있어야 합니다.

### 3.3 Delegate Action 패턴 — 자식이 부모에게 알리는 유일한 통로

자식 Feature가 **부모에게 알려야 하는 결과**는 반드시 `delegate(_)`로 통일합니다.
부모는 자식의 일반 Action을 직접 듣지 않습니다.

```swift
// 자식 (PolicyDetailFeature)
case .didTapDelete:
  return .run { [id = state.id] send in
    try await policyClient.delete(id)
    await send(.delegate(.policyDeleted(id)))
  }

// 부모 (PolicyListFeature)
case .destination(.presented(.detail(.delegate(.policyDeleted(let id))))):
  state.policies.remove(id: id)
  return .none
```

> **왜 delegate를 따로 두는가?**
> 자식의 일반 Action(`didTapDelete`, `policiesResponse` 등)은 *자식 내부의 사정*입니다. 부모가 이걸 직접 듣기 시작하면 "자식 구현을 바꾸면 부모도 같이 깨지는" 결합이 생깁니다.
> Delegate는 자식이 부모에게 노출하는 **공개 인터페이스**입니다. 자식 내부 Action을 자유롭게 바꿔도 Delegate 표면만 유지하면 부모는 영향을 받지 않습니다.

> **Rule:** 자식이 부모의 State를 직접 알면 안 됩니다. 자식은 "내가 한 일"만 알리고, 부모가 그것을 어떻게 처리할지 결정합니다.

지금 `AppCoordinator`가 각 탭·모달의 상태를 중앙에서 직접 조작하는 방식과 가장 크게 달라지는 지점이 이 규칙입니다. TCA에서는 그런 중앙 조작이 없고, 오직 delegate를 통한 상향 통지만 있습니다.

#### 처음엔 이렇게 쓰기 쉬워요 (그리고 왜 문제인지)

```swift
// ❌ Bad — 부모가 자식의 일반 Action을 듣고 분기
case .destination(.presented(.detail(.didTapDelete))):
  // 부모가 자식 내부의 동작 순서를 가정함
  state.policies.remove(id: ???)
  return .none
```

위 코드는 "자식이 *지금* 어떤 순서로 동작하는지"에 의존합니다. 자식 구현이 바뀌면(예: 삭제 전에 확인 다이얼로그를 띄우게 됐다면) 부모가 바로 깨집니다.

### 3.4 Equatable

Action은 **가능한 한 `Equatable`을** 채택합니다. `TestStore`에서 동등 비교가 필요하기 때문입니다.
`Error` 등 Equatable이 안 되는 타입은 별도 wrapper(`EquatableError`)로 감싸거나 `Result`의 동등 비교를 위해 Error를 의미 있는 enum으로 매핑합니다.

```swift
// ✅ 도메인 에러를 enum으로 매핑
enum PolicyLoadError: Error, Equatable {
  case network
  case notFound
  case unauthorized
}

case policiesResponse(Result<[Policy], PolicyLoadError>)
```

---

## 4. Reducer

### 4.1 형태

- `@Reducer` 매크로 사용
- `var body: some ReducerOf<Self>` 안에서 `Reduce { state, action in ... }`
- 자식 결합은 `Scope`, `ifLet`, `forEach` 등의 오퍼레이터로

```swift
@Reducer
struct PolicyListFeature {

  @ObservableState
  struct State: Equatable { /* ... */ }

  enum Action: Equatable { /* ... */ }

  @Dependency(\.policyClient) var policyClient

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      // ...
      }
    }
    .ifLet(\.$destination, action: \.destination) {
      Destination()
    }
  }
}
```

### 4.2 Reducer 안에서는 절대 하지 말 것

| 금지 동작 | 왜 | 대안 |
|---|---|---|
| `Task { ... }` 직접 띄우기 | 취소 불가, 테스트에서 시간 제어 불가 | `.run { send in ... }` |
| `URLSession`, `FileManager`, `Date()`, `UUID()` 직접 호출 | 외부 자원에 직접 의존 → 테스트 불가 | `@Dependency` |
| State를 Reducer 밖에서 변경 (View, Effect 클로저 내부) | 단방향 흐름 위반 | Action을 보내서 변경 |
| View 표현 결정 (색·문자열) | 책임 경계 위반 | View가 책임 |
| 다른 Feature의 State를 직접 참조 | 결합도 폭발 | 부모를 통해 데이터 전달 |

### 4.3 case 본문은 짧게

case 본문이 5~10줄을 넘으면 **private helper**로 분리합니다.

```swift
// ✅ Good
case .policiesResponse(.success(let policies)):
  return handlePoliciesLoaded(state: &state, policies: policies)

// helper
private func handlePoliciesLoaded(
  state: inout State,
  policies: [Policy]
) -> Effect<Action> {
  state.isLoading = false
  state.policies = IdentifiedArray(uniqueElements: policies)
  return .none
}
```

> **왜?**
> `Reduce` 본문이 길어지면 switch 한 화면에 안 들어오기 시작합니다. switch는 "Action 목차"의 역할을 해야 하므로, *목차에 들어갈 한 줄*과 *세부 구현*은 분리합니다.

### 4.4 switch는 **반드시 exhaustive**

`default:`를 쓰지 않습니다. Action이 늘었을 때 컴파일러가 잡아주는 안전망을 포기하지 마세요.

```swift
// ❌ Bad
switch action {
case .didTapAddButton: ...
default: return .none
}

// ✅ Good — 모든 케이스 명시
switch action {
case .didTapAddButton: ...
case .didChangeSearchText(let text): ...
case .policiesResponse(.success(let policies)): ...
case .policiesResponse(.failure(let error)): ...
case .destination: return .none
case .delegate: return .none
}
```

> **자주 하는 질문: "그럼 변화 없는 케이스는요?"**
> `return .none`을 명시적으로 적어주세요. "이 Action은 들어와도 무시한다"는 결정이 코드에 남아 있어야 합니다. `default`로 묶어버리면 새 Action을 추가했을 때 "어 이건 처리 안 한 건가, 무시인가?"를 알 수 없습니다.

---

## 5. Effect & 비동기

### 5.1 비동기는 `.run`

```swift
// ✅ Good
case .onAppear:
  state.isLoading = true
  return .run { send in
    do {
      let policies = try await policyClient.fetchAll()
      await send(.policiesResponse(.success(policies)))
    } catch {
      await send(.policiesResponse(.failure(error)))
    }
  }

// ❌ Bad
case .onAppear:
  Task { @MainActor in
    let policies = try await policyClient.fetchAll()
    // state를 여기서 못 바꿈
  }
  return .none
```

> **왜 Task가 안 되나?**
> `Task { }`는 Reducer가 끝나면 사라지는 별도 흐름입니다. 취소도 못 하고, 결과를 State로 가져올 길이 없고, TestStore도 추적 못 합니다.
> `.run { send in }`은 TCA가 Effect로 관리합니다 — 화면이 사라지면 자동 취소되고, `send(.액션)`으로 결과를 다시 Reducer 흐름에 합류시킬 수 있습니다.

### 5.2 취소 가능한 Effect

검색·디바운스 등 **이전 작업을 취소해야 하는 Effect**는 `cancellable(id:)`를 씁니다.
ID는 이 Feature 내부에서만 쓰이는 **private enum**으로 정의하고, 그 안에 취소 작업별 `case`를 나열합니다.

```swift
private enum CancelID { case search }

case .didChangeSearchText(let text):
  state.searchText = text
  return .run { send in
    try await clock.sleep(for: .milliseconds(300))
    do {
      let policies = try await policyClient.search(text)
      await send(.searchResponse(.success(policies)))
    } catch {
      await send(.searchResponse(.failure(error)))
    }
  }
  .cancellable(id: CancelID.search, cancelInFlight: true)
```

> **`cancelInFlight: true`의 의미**
> 같은 `id`로 이미 진행 중인 Effect가 있다면 **자동으로 취소하고** 새로운 Effect를 시작합니다. 검색어를 빠르게 타이핑할 때 매번 새 Effect만 살아 있게 됩니다.

> **언제 cancellable을 도입하나?**
> *"같은 동작을 짧은 시간에 여러 번 일으킬 수 있는가?"* 가 판단 기준입니다.
> - 검색어 입력 (매 키 입력) → 필요 (ChungBazi의 `PolicySearch` 화면이 대표 사례)
> - 디바운스가 필요한 자동 저장 → 필요
> - 화면 진입 시 1회 fetch → 보통 불필요 (단, 화면이 사라질 때 취소되어야 한다면 도입)

### 5.3 State capture는 명시적으로

`.run` 클로저는 State 전체를 캡처할 수 없습니다(값타입이라 스냅샷). **필요한 값만 캡처 리스트에 명시**합니다.

```swift
// ✅ Good
return .run { [id = state.id, title = state.title] send in
  try await client.save(id: id, title: title)
  await send(.delegate(.policySaved))
}

// ❌ Bad — state 전체를 캡처하려는 시도
return .run { send in
  try await client.save(id: state.id, title: state.title)  // ❌ 컴파일 오류 또는 의도와 다른 동작
}
```

> **왜 캡처 리스트가 필요한가?**
> Effect는 Reducer가 끝난 *뒤*에도 살아 있습니다. 그 사이 State가 또 바뀔 수 있죠. 캡처 리스트로 "Effect가 시작될 때의 값"을 박제해 두지 않으면, Effect가 어떤 시점의 State를 봐야 하는지가 모호해집니다.

### 5.4 에러는 Reducer에서 처리

`.run`에서 `try`로 던지면 반드시 잡아 응답 Action으로 돌려보냅니다. Effect 안에서 묵살하지 않습니다.

```swift
// 패턴 A — .run 내부 do/catch
return .run { send in
  do {
    let policies = try await policyClient.fetchAll()
    await send(.policiesResponse(.success(policies)))
  } catch {
    await send(.policiesResponse(.failure(error)))
  }
}

// 패턴 B — .run의 catch: 클로저
return .run { send in
  let policies = try await policyClient.fetchAll()
  await send(.policiesResponse(.success(policies)))
} catch: { error, send in
  await send(.policiesResponse(.failure(error)))
}
```

> **두 패턴 중 무엇을 쓰나?**
> 여러 `try`가 얽혀 있으면 패턴 A (한 do 블록으로 묶이니 흐름이 명확). 성공 경로가 짧고 에러 처리를 한 줄로 처리하면 패턴 B.

> **Swift 6에서는 `Result { try await ... }` 축약도 가능**
> `Result`의 async throwing initializer는 Swift 6.4의 [SE-0530](https://github.com/apple/swift-evolution/blob/main/proposals/0530-async-result-support.md)부터 도입됐습니다. ChungBazi는 Swift 6 언어 모드(`SWIFT_VERSION = 6.0`)를 사용하므로, 툴체인이 SE-0530을 지원하는 버전이라면 아래처럼 한 줄로 줄일 수 있습니다.
>
> ```swift
> case .task:
>   state.isLoading = true
>   return .run { send in
>     let result = await Result { try await policyClient.fetchAll() }
>     await send(.policiesResponse(result))
>   }
> ```
>
> 다만 이 축약은 단일 `try await` 호출에만 깔끔하게 들어맞습니다. `do/catch`로 여러 `try`를 하나의 에러 타입으로 매핑해야 하는 경우(예: 네트워크 에러 → 도메인 에러 변환)에는 여전히 패턴 A가 더 명확하므로, 팀 컨벤션으로 **"단일 호출은 `Result { }` 축약, 다단계 에러 매핑은 패턴 A"**를 기준으로 삼습니다.

---

## 6. Dependency

> 가장 자주 오해되는 절입니다. **TCA는 `BaziPresentation`·App 타겟(`ChungBazi`)에만 살고, `BaziDomain`·`BaziData`는 TCA를 모릅니다.**
> Client *인터페이스*는 `BaziPresentation`에, *`liveValue` 조립*은 App 타겟(Composition Root)에 둡니다.

### 6.1 TCA의 영향 범위 — Composition Root 분리 원칙

`import ComposableArchitecture`가 들어가는 모듈은 **`BaziPresentation`과 App 타겟(`ChungBazi`)** 두 개입니다. 두 모듈의 역할은 다릅니다.

| 모듈 | 역할 | 알고 있는 것 |
|---|---|---|
| `BaziPresentation` | Feature(Reducer/View) + Client **인터페이스** + `testValue`/`previewValue` | TCA + `BaziDomain` (※ `BaziData`는 모름) |
| `ChungBazi` (App 타겟) | Client의 **`liveValue` 조립** = Composition Root | TCA + `BaziPresentation` + `BaziDomain` + `BaziData` |
| `BaziDomain` | 비즈니스 규칙(프로토콜·엔티티·에러) | TCA를 모름 |
| `BaziData` | Repository 구현체 (`BaziNetwork`·`BaziStorage`에 의존) | TCA를 모름 |
| `BaziNetwork`, `BaziStorage` | Moya 기반 API 호출, Keychain/UserDefaults | TCA를 모름 |

의존 화살표 (실제 `Project.swift` 의존성 선언 기준):

```text
ChungBazi (App, @main)         ← Composition Root (모든 레이어 알 권한 있음)
   │
   ├─ liveValue 정의 (PolicyClient+Live.swift 등)
   │
   ▼
BaziPresentation                ← TCA가 사는 곳, 단 BaziData는 모름
   │
   ├─ Feature (Reducer/View)
   ├─ Client struct + TestDependencyKey (testValue, previewValue)
   │
   ▼
BaziDomain  ←──  BaziData        ← TCA를 모르는 순수 레이어
                    ▲
                    │
            BaziNetwork, BaziStorage   ← Moya API, Keychain, UserDefaults 등 실제 구현
```

`BaziData`는 `BaziDomain`·`BaziNetwork`·`BaziStorage`에 의존하는 구현 레이어이고, `ChungBazi` 앱 타겟은 `BaziPresentation`과 `BaziData`를 **둘 다** 직접 의존성으로 갖고 있어(`Project.swift` 확인됨) Composition Root 역할을 하기에 이미 적합한 구조입니다.

> **왜 두 단계로 나누나? (Composition Root 패턴)**
> Robert C. Martin *Clean Architecture* 책의 표현 그대로 옮기면:
> > "어딘가는 추상을 구체로 묶어야 한다. 그 한 점을 *Composition Root*라 부르고, 보통 `main()` 가장 가까운 곳에 둔다."
>
> Composition Root는 의존성 규칙의 **공식 예외**입니다. 그 한 점만 모든 레이어를 알아도 됩니다. 비즈니스 로직을 수행하지 않고 *그래프 조립*만 하기 때문입니다. ChungBazi에서는 그 한 점이 **App 타겟 `ChungBazi`** 입니다.

> **왜 `BaziPresentation`에 `BaziData` import를 막나?**
> - `BaziPresentation`이 `BaziData`를 모르면 *Feature 단위 빌드/Preview/단위 테스트가 가벼워집니다.* Moya의 네트워크 스택, Keychain 의존성 등을 불러올 필요가 없어집니다.
> - 모듈 수준에서도 의존 화살표가 *바깥쪽 → 안쪽(Domain)* 으로만 흐릅니다. 코드 단위 뿐 아니라 모듈 단위에서도 클린 아키텍처가 지켜집니다.

> **왜 Domain/Data에 TCA를 못 넣게 하나?**
> - `BaziDomain`은 *비즈니스 규칙*만 담은 순수 레이어입니다. TCA를 import하는 순간 다른 환경(위젯, CLI 툴 등)에서 재사용 불가능해집니다.
> - TCA 버전 변경이 Domain/Data 빌드까지 깨뜨립니다.
> - Domain만 단독으로 단위 테스트하기 어려워집니다.

### 6.2 모든 외부 의존은 `@Dependency`

`policyClient`, `clock`, `uuid`, `date`, `mainQueue` 등 **시간·랜덤·외부 자원은 전부 Dependency로**.

```swift
@Reducer
struct PolicyListFeature {
  @Dependency(\.policyClient) var policyClient
  @Dependency(\.uuid) var uuid
  @Dependency(\.continuousClock) var clock
  @Dependency(\.date.now) var now
}
```

> **왜 `UUID()`를 직접 못 쓰나?**
> 테스트에서 `let id = UUID()`를 검증하려면 매번 다른 값이 나옵니다. `@Dependency(\.uuid)`로 받으면 테스트에서 `$0.uuid = .incrementing`처럼 *예측 가능한* 값으로 바꿔치기할 수 있습니다.

### 6.3 왜 프로토콜을 그대로 못 쓰나 — 어댑터가 필요한 세 가지 이유

`BaziDomain`에 UseCase 프로토콜을 정의하게 되면(예: `FetchPolicyUseCase`) 아래와 같은 모양이 될 것입니다.

```swift
// BaziDomain
public protocol FetchPolicyUseCase: Sendable {
  func fetch(id: Int) async throws -> Policy?
  func fetch(query: PolicyQuery) async throws -> [Policy]
}
```

이걸 Reducer에서 그대로 받고 싶다고 가정해 봅시다.

```swift
// ❌ 이게 안 되는 이유
@Reducer
struct PolicyListFeature {
  @Dependency(\.fetchPolicyUseCase) var fetchUseCase  // 어떻게 DependencyKey 등록?
}
```

**문제 ①** `@Dependency`로 받으려면 **`DependencyKey`에 conform한 구체 타입**이 필요합니다. `protocol FetchPolicyUseCase`는 자신이 다른 프로토콜에 conform할 수 없고, *어떤 구현체가 testValue인가?* 답이 없습니다.

**문제 ②** TCA의 `testValue`는 "호출하면 즉시 실패"하는 **unimplemented가 기본**입니다. 프로토콜에는 그런 기본값을 박을 수 없어, mock 클래스를 매번 손으로 만들어야 합니다.

**문제 ③** 제네릭 메서드는 TCA `@DependencyClient` 매크로가 못 다룹니다. 클로저 프로퍼티는 제네릭을 가질 수 없기 때문입니다.

→ 그래서 **클로저 타입의 struct (= Client)** 가 필요합니다. 프로토콜을 한 번 *어댑팅*해서 TCA가 알아먹는 모양으로 변환하는 거예요.

### 6.4 Client 정의 패턴 — 두 모듈에 나눠 둔다

Client는 두 부분으로 나뉘어 서로 다른 모듈에 살고, TCA의 `TestDependencyKey`/`DependencyKey` 분리가 정확히 이 용도를 위해 설계되어 있습니다.

| 부분 | 위치 | 역할 |
|---|---|---|
| `struct {이름}Client` + `TestDependencyKey` + `DependencyValues` 키 | `BaziPresentation/Sources/Dependencies/{이름}Client.swift` | 인터페이스 + 테스트/프리뷰 기본값 |
| `extension {이름}Client: DependencyKey` (`liveValue`) | `ChungBazi/Sources/Dependencies/{이름}Client+Live.swift` | 실제 의존성 그래프 조립 (Composition Root) |

`liveValue` 정의는 App 타겟이 로드될 때 자동으로 등록되어, 런타임에 `@Dependency(\.policyClient)`가 알아서 `liveValue`를 집어 옵니다.

#### 1단계: 인터페이스 정의 — `BaziPresentation`에 둔다

UseCase 1개당 Client 1개가 아닙니다. **화면이 필요로 하는 인터페이스 묶음**이 Client 한 개입니다. `PolicyList` 화면이 Fetch/Search를 모두 쓴다면 하나의 `PolicyClient`로 묶습니다.

```swift
// BaziPresentation/Sources/Dependencies/PolicyClient.swift
import ComposableArchitecture
import BaziDomain   // ← Domain의 protocol·entity·error만 가져옴 (BaziData 없음!)
import Foundation

@DependencyClient
struct PolicyClient: Sendable {
  var fetchByID: @Sendable (_ id: Int) async throws -> Policy?
  var fetchAll: @Sendable () async throws -> [Policy]
  var search: @Sendable (_ query: String) async throws -> [Policy]
}

extension PolicyClient: TestDependencyKey {
  static let testValue = PolicyClient()    // 전부 unimplemented

  static let previewValue = PolicyClient(
    fetchByID: { _ in Policy.mock },
    fetchAll:  { Policy.mockList },
    search:    { _ in Policy.mockList }
  )
}

extension DependencyValues {
  var policyClient: PolicyClient {
    get { self[PolicyClient.self] }
    set { self[PolicyClient.self] = newValue }
  }
}
```

**여기까지 `BaziPresentation`은 `BaziData`를 전혀 import하지 않습니다.** `@DependencyClient` 매크로가 자동으로 `init`, `unimplemented` 기본값을 만들어 줍니다.

> **`TestDependencyKey` vs `DependencyKey`**
> - `TestDependencyKey`: `testValue` + `previewValue`만 요구. *인터페이스 모듈*용.
> - `DependencyKey`: `TestDependencyKey`를 상속하며 `liveValue`도 요구. *Composition Root*용.
> 분리해서 정의하면 인터페이스 모듈은 Live 의존성을 모른 채로 빌드·테스트할 수 있습니다.

#### 2단계: `liveValue` 조립 — App 타겟(Composition Root)에 둔다

`liveValue`만 별도 파일로 App 타겟에 둡니다. **여기가 ChungBazi의 유일한 Composition Root**입니다. UseCaseImpl + RepositoryImpl을 *오직 이 한 곳에서만* 조립합니다.

```swift
// ChungBazi/Sources/Dependencies/PolicyClient+Live.swift
import ComposableArchitecture
import BaziPresentation
import BaziDomain
import BaziData

extension PolicyClient: DependencyKey {

  static let liveValue: PolicyClient = {
    // ⬇️ Composition Root — Impl 인스턴스화는 전부 여기서만 일어남
    let repository: any PolicyRepository = PolicyRepositoryImpl()
    let fetchUseCase: any FetchPolicyUseCase = FetchPolicyUseCaseImpl(repository: repository)

    return PolicyClient(
      fetchByID: { try await fetchUseCase.fetch(id: $0) },
      fetchAll:  { try await fetchUseCase.fetch(query: .all) },
      search:    { try await fetchUseCase.fetch(query: .keyword($0)) }
    )
  }()
}
```

| 값 | 정의 위치 | 언제 쓰이나 | 동작 |
|---|---|---|---|
| `liveValue` | App 타겟 (`ChungBazi`) | 실제 앱 실행 | `BaziData`의 Impl 조립 후 실제 호출 |
| `testValue` | `BaziPresentation` | XCTest | 호출하면 즉시 실패 — *override 안 한 호출을 잡아내는 안전망* |
| `previewValue` | `BaziPresentation` | SwiftUI Preview | 즉시 mock 데이터 반환 |

> **왜 testValue는 unimplemented가 기본인가?**
> 테스트할 때 *내가 명시적으로 override하지 않은 의존성*이 호출되면 *그 호출이 일어났다는 사실 자체가 버그*입니다. unimplemented는 그 호출에서 즉시 테스트를 실패시켜 알려줍니다.

> **`static let liveValue = { ... }()`는 lazy + 1회 평가**
> 앱 전체에서 한 번만 조립됩니다. 무거운 인스턴스는 거기서 한 번만 만들어 클로저들이 캡처합니다.

#### 3단계: 자동 등록 확인 — 별도 wiring 불필요

`@Dependency(\.policyClient)`는 런타임 컨텍스트(live/test/preview)에 따라:
- App 실행 중 → `DependencyKey.liveValue` (`ChungBazi` 모듈에서 발견)
- XCTest 중 → `TestDependencyKey.testValue`
- Preview 중 → `TestDependencyKey.previewValue`

App 타겟이 로드되는 순간 `DependencyKey` conformance가 자동 등록되므로, **`ChungBaziApp.swift`에서 별도의 wiring 코드는 필요 없습니다.**

> **추가 제어가 필요할 때**
> 통합 테스트나 빌드 변형에서 일부 Dependency만 미리 override하고 싶다면 App 시작 시 `prepareDependencies { $0.policyClient = .liveValue }`를 호출할 수 있습니다. 평상시엔 생략해도 됩니다.

### 6.5 Reducer에서의 사용

`PolicyClient`가 준비됐다면 Reducer는 깔끔합니다.

```swift
// BaziPresentation/Sources/Features/PolicyList/PolicyListFeature.swift
import ComposableArchitecture
import BaziDomain    // Policy, PolicyQuery, PolicyUseCaseError 같은 도메인 어휘만

@Reducer
struct PolicyListFeature {

  @ObservableState
  struct State: Equatable {
    var policies: IdentifiedArrayOf<Policy> = []
    var isLoading = false
  }

  enum Action: Equatable {
    case task
    case policiesResponse(Result<[Policy], PolicyUseCaseError>)
    case delegate(Delegate)
    enum Delegate: Equatable {}
  }

  @Dependency(\.policyClient) var policyClient

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .task:
        state.isLoading = true
        return .run { send in
          do {
            let policies = try await policyClient.fetchAll()
            await send(.policiesResponse(.success(policies)))
          } catch {
            await send(.policiesResponse(.failure(PolicyUseCaseError.map(error))))
          }
        }

      case .policiesResponse(.success(let policies)):
        state.isLoading = false
        state.policies = IdentifiedArray(uniqueElements: policies)
        return .none

      case .policiesResponse(.failure):
        state.isLoading = false
        return .none

      case .delegate:
        return .none
      }
    }
  }
}
```

Reducer는 **`BaziDomain`만 import**합니다. `PolicyClient` 인터페이스는 같은 모듈(`BaziPresentation`) 안에 있어 자동으로 보입니다.

### 6.6 자주 빠지는 함정

**함정 ① "UseCase 1개당 Client 1개?"**
→ 아닙니다. **화면 단위로 묶는 게 자연스럽습니다.** `PolicyClient` 하나가 Fetch/Search/Bookmark UseCase를 모두 잡아도 OK. 어댑터의 결합 단위는 *Feature가 필요로 하는 인터페이스 묶음*입니다.

**함정 ② "liveValue에서 Impl을 매번 new 하면 비싸지 않나?"**
→ `static let liveValue = { ... }()`는 **lazy + 1회 평가**입니다. 앱 전체에서 한 번만 조립되고, 무거운 인스턴스는 거기서 한 번 만들어 클로저들이 캡처합니다.

**함정 ③ "그럼 BaziPresentation에서는 BaziData를 어떻게 쓰지?"**
→ **쓰지 않습니다.** `BaziPresentation`은 인터페이스(`PolicyClient` struct)와 mock(`testValue`/`previewValue`)만 압니다. 실제 Impl 조립은 App 타겟 `ChungBazi`의 `+Live.swift` 파일이 책임집니다.

**함정 ④ "Reducer가 Domain의 에러 타입을 알면 결합도가 높아지지 않나?"**
→ Domain 모델(Entity, Error enum)은 **공유 어휘**입니다. View/Feature가 도메인 어휘를 아는 건 결합도가 아니라 응당함입니다. 결합도가 문제가 되는 건 *Reducer가 Repository 구현체나 Data 레이어 세부를 아는 경우*뿐입니다.

**함정 ⑤ "liveValue가 App 타겟에 있으면 @Dependency가 자동으로 찾아주나?"**
→ 네. App 타겟이 로드되면 `extension PolicyClient: DependencyKey`의 conformance가 등록되고, 런타임 환경(live)에 따라 자동으로 `liveValue`가 선택됩니다. 별도 wiring 코드는 필요 없습니다.

### 6.7 금지 사항

- ❌ `BaziDomain`/`BaziData`/`BaziNetwork`/`BaziStorage`에서 `import ComposableArchitecture` — **절대 금지**
- ❌ `BaziPresentation`에서 `import BaziData` — Live 조립은 App 타겟이 담당
- ❌ `BaziPresentation`에 `DependencyKey.liveValue`를 정의 — `TestDependencyKey`만 정의
- ❌ Reducer 안에서 싱글톤 직접 호출 (`SomeService.shared.foo()`)
- ❌ Reducer 안에서 `UseCaseImpl()` / `RepositoryImpl()`을 직접 인스턴스화 — `liveValue` 안에서만
- ❌ `BaziDomain` UseCase 프로토콜을 직접 `@Dependency`로 받기 — Client로 감싸기
- ❌ `@Dependency`를 View나 외부 함수에서 읽기 — Reducer 안에서만 의미가 있음

---

## 7. Navigation & Composition

가장 헷갈리는 절입니다. **상황별 의사결정 트리**부터 보세요.

```text
화면 위에 다른 화면을 띄우고 싶다
    │
    ├── 0~1개만 떠 있다 (시트/풀스크린/알럿/다이얼로그)
    │       → 7.1  @Presents + ifLet + Destination enum
    │
    ├── 푸시 스택처럼 여러 화면이 쌓인다 (NavigationStack)
    │       → 7.2  StackState + forEach + Path enum
    │
    └── 동일 타입 자식이 여러 개 동시에 존재한다 (리스트의 행 등)
            → 7.3  IdentifiedArrayOf + forEach
```

> 지금의 `Coordinator/` 디렉토리(`AppCoordinator`, `TabCoordinator`, `HomeRoute` 등)는 이 장의 패턴으로 대체됩니다. `AppPhase`/`AuthRoot`/`MainTab`은 `AppFeature`의 최상위 상태 분기로, 탭별 `NavigationPath`는 각 탭 루트 Feature의 `StackState<Path.State>`로, `ModalRoute`는 해당 화면의 `@Presents var destination`으로 흡수됩니다.

### 7.1 단일 자식 화면 — `@Presents` + `ifLet`

시트·풀스크린·알럿 등 **0~1개 떠 있는** 화면. 같은 위치에 *어떤 화면이 떠 있을지*는 enum으로 표현합니다.

```swift
@ObservableState
struct State: Equatable {
  @Presents var destination: Destination.State?
}

@Reducer
enum Destination {
  case detail(PolicyDetailFeature)
  case addSheet(AddMemoFeature)
  case deleteAlert(AlertState<Action.Alert>)
}
// Destination.State는 자동으로 Equatable을 준수하지 않는다 — 7.5절 참고
extension Destination.State: Equatable {}

var body: some ReducerOf<Self> {
  Reduce { state, action in /* ... */ }
    .ifLet(\.$destination, action: \.destination)
}
```

> **왜 enum으로 묶나?**
> "한 번에 떠 있는 건 하나뿐"이라는 사실을 *타입으로* 표현합니다. `var sheet: AddMemoFeature.State?`, `var alert: AlertState?`, `var detail: PolicyDetailFeature.State?` 세 개를 각각 두면 *둘 이상이 동시에 nil이 아닌* 잘못된 상태가 모델링됩니다. enum이면 그게 불가능합니다.

### 7.2 스택 네비게이션 — `StackState` + `forEach`

```swift
@ObservableState
struct State: Equatable {
  var path = StackState<Path.State>()
}

@Reducer
enum Path {
  case detail(PolicyDetailFeature)
  case categoryPolicyList(CategoryPolicyListFeature)
}
// Path.State는 자동으로 Equatable을 준수하지 않는다 — 7.5절 참고
extension Path.State: Equatable {}

var body: some ReducerOf<Self> {
  Reduce { state, action in /* ... */ }
    .forEach(\.path, action: \.path)
}
```

> **언제 StackState?**
> `NavigationStack`처럼 *깊이 들어갔다 돌아오기*를 표현할 때. 시트는 0~1개 자식이지만 스택은 N개 자식이 *순서대로* 쌓입니다. 지금의 `HomeRoute`/`SearchRoute`/`MyPolicyRoute`/`ProfileRoute` 케이스들이 각 탭의 `Path` enum 케이스로 옮겨갑니다.

### 7.3 동등한 자식 컬렉션 — `forEach`

리스트의 각 행이 자체 Feature를 가진 경우.

```swift
@ObservableState
struct State: Equatable {
  var rows: IdentifiedArrayOf<PolicyRowFeature.State> = []
}

enum Action {
  case rows(IdentifiedActionOf<PolicyRowFeature>)
}

var body: some ReducerOf<Self> {
  Reduce { /* ... */ }
    .forEach(\.rows, action: \.rows) {
      PolicyRowFeature()
    }
}
```

> **언제 행을 Feature로 만드나?**
> 행마다 *독립적인 상태*(로딩, 북마크 토글, 펼침/접힘 등)나 *독립적인 사이드 이펙트*가 필요할 때.
> 행이 단순한 표시용 카드라면 그냥 `IdentifiedArrayOf<Policy>`를 State에 두고, 행 컴포넌트는 평범한 SwiftUI View로 두는 게 가볍습니다.

### 7.4 Composition 원칙

- **부모는 자식의 State를 alloc/dealloc하고, 자식의 delegate Action만 듣는다.**
- 자식의 일반 Action에 부모가 분기를 다는 일은 최소화한다.
- 두 자식이 서로 통신해야 하면 **공통 부모를 통해** 한다. 자식끼리 직접 연결하지 않는다.

### 7.5 필수 — `@Reducer enum`(Path/Destination)의 `State`는 직접 `Equatable`을 확장해야 함

`@Reducer enum Path { case detail(SomeFeature) }` 처럼 아무 확장 없이 쓰면 아래 에러가 납니다.

- `Type 'XFeature.State' does not conform to protocol 'Equatable'` (에러가 `Path` 선언 위치에 표시됨)
- `'XFeature.Path' cannot be constructed because it has no accessible initializers` (`.forEach`/`.ifLet`에 불필요한 trailing closure를 추가로 붙였을 때 같이 발생하기 쉬움)

**원인**: `.build/checkouts/swift-composable-architecture/Sources/ComposableArchitectureMacros/ReducerMacro.swift`(1.26.0 기준)를 직접 열어 확인한 결과, `@Reducer` enum 매크로가 생성하는 `State`는 기본적으로 `ComposableArchitecture.CaseReducerState`에만 준수하고 **`Equatable`은 자동으로 붙지 않습니다.**

**해결 (Swift 6, 권장)**: `Destination`/`Path` 선언 직후에 **직접 extension으로 `Equatable`을 붙입니다.** 공식 문서([`Reducer.md#Synthesizing-protocol-conformances-on-State-and-Action`](https://github.com/pointfreeco/swift-composable-architecture))가 안내하는 방식입니다.

```swift
// ✅ Good — Swift 6
@Reducer
enum Path {
  case detail(PolicyDetailFeature)
}
extension Path.State: Equatable {}
```

> **`@Reducer(state: .equatable)`는 쓰지 않습니다 — deprecated**
> `Reducer(state:action:)` 매크로 오버로드는 "Define your conformance using an extension, instead"라는 메시지로 **deprecated** 처리되어 있습니다(TCA 소스의 `@available(*, deprecated, ...)` 확인). 원래 Swift 6 미만에서 `extension Path.State: Equatable {}`가 컴파일러 버그로 막혀 있던 시절의 우회책이었습니다. ChungBazi는 Swift 6이므로 **항상 extension 방식**을 씁니다.
>
> ```swift
> // ❌ Bad — deprecated, 경고 발생
> @Reducer(state: .equatable)
> enum Path {
>   case detail(PolicyDetailFeature)
> }
> ```

`Path`가 부모 Feature 안에 중첩되어 있다면, extension은 부모 struct **밖에서** 완전한 경로로 씁니다.

```swift
@Reducer
struct HomeFeature {
  @Reducer
  enum Path {
    case detail(PlaceholderDetailFeature)
  }
  // ...
}

// HomeFeature 밖, 파일 최상위
extension HomeFeature.Path.State: Equatable {}
```

12절 체크리스트에도 반영되어 있습니다(G4).

---

## 8. View

### 8.1 Store 보유

- 루트 View: `let store: StoreOf<Feature>` 또는 `@Bindable var store`
- 양방향 바인딩이 필요한 화면: `@Bindable var store: StoreOf<Feature>`

```swift
public struct PolicyListView: View {

  // MARK: - Properties

  @Bindable var store: StoreOf<PolicyListFeature>

  // MARK: - Init

  public init(store: StoreOf<PolicyListFeature>) {
    self.store = store
  }

  // MARK: - Body

  public var body: some View {
    content
      .task { store.send(.task) }
      .sheet(
        item: $store.scope(state: \.destination?.addSheet, action: \.destination.addSheet)
      ) { addStore in
        AddMemoView(store: addStore)
      }
  }
}

// MARK: - Subviews

extension PolicyListView {

  private var content: some View {
    NavigationStack {
      // ...
    }
  }
}

// MARK: - Preview

#Preview {
  PolicyListView(
    store: Store(initialState: .init()) {
      PolicyListFeature()
    }
  )
}
```

> **`@Bindable` vs `let`**
> View 안에서 `$store.searchText` 같은 양방향 바인딩이 *필요하면* `@Bindable`. 아니면 그냥 `let`.

### 8.2 View 본문 규칙

[CODING_GUIDELINES §3](./CODING_GUIDELINES.md#3-swiftui-뷰-구조) 그대로 적용하되, TCA View는 아래 MARK 섹션 순서를 고정 컨벤션으로 씁니다.

| 섹션 | 내용 |
|---|---|
| `// MARK: - Properties` | `store` 보유 |
| `// MARK: - Init` | 이니셜라이저 |
| `// MARK: - Body` | `var body` — 최상위 컨테이너 하나만, 대부분 `content`를 그대로 반환 |
| `// MARK: - Subviews` | `private` 하위뷰(`content` 등) — 별도 `extension`으로 분리 |
| `// MARK: - Preview` | `#Preview` |

- `var body`에는 **최상위 컨테이너 하나**만
- 하위뷰는 `extension`에서 `private`로, `// MARK: - Subviews` 섹션에 모읍니다

### 8.3 View에서 절대 하지 말 것

- ❌ View에서 `Task { ... }` 띄우고 비동기 작업
- ❌ View에서 직접 `@Dependency` 읽기
- ❌ `store.state.foo` 형태로 깊이 읽기 — Observation이 알아서 추적하니까 `store.foo`로 충분
- ❌ `ViewStore`, `WithViewStore` 사용 (Observation 시대엔 deprecated 패턴)
- ❌ View에서 `if let` 으로 자식 상태 분기 후 자체 분기 처리 — 그건 Destination enum의 일

```swift
// ✅ Good
Text(store.title)
Button("Add") { store.send(.didTapAddButton) }

// ❌ Bad — 옛날 자료 보고 따라 쓰기 쉬움
WithViewStore(store, observe: { $0 }) { viewStore in
  Text(viewStore.title)
}
```

> **인터넷에서 옛날 TCA 코드를 봤다면**
> `ViewStore`, `WithViewStore`, `viewStore.binding(get:send:)` 같은 패턴은 Observation 도입 이전 시대 코드입니다. 지금은 `@ObservableState` + `@Bindable`로 단순화됐어요. 옛날 패턴을 신규 코드에 도입하지 마세요.

### 8.4 바인딩

```swift
// ✅ Good — @ObservableState + @Bindable이면 $store.프로퍼티로 바로 바인딩
TextField("Search", text: $store.searchText)

// ❌ Bad — 옛날 방식
TextField("Search", text: viewStore.binding(get: \.searchText, send: ...))
```

> 이를 위해 Action에는 `BindableAction` + `binding(_:)` 케이스를 채택해도 좋습니다.

```swift
enum Action: BindableAction, Equatable {
  case binding(BindingAction<State>)
  case didTapAddButton
  // ...
}

var body: some ReducerOf<Self> {
  BindingReducer()
  Reduce { /* ... */ }
}
```

> **`BindingReducer`는 언제?**
> State 필드 *여러 개를* View에서 직접 편집할 때(폼 입력 등). 매 필드마다 `didChangeFoo(String)` Action을 만들지 않아도 됩니다.

---

## 9. Testing

### 9.1 TestStore 기본형

```swift
@MainActor
func test_task_loadsPolicies() async {
  let store = TestStore(initialState: PolicyListFeature.State()) {
    PolicyListFeature()
  } withDependencies: {
    $0.policyClient.fetchAll = { [Policy.mock1, Policy.mock2] }
  }

  await store.send(.task) {
    $0.isLoading = true
  }
  await store.receive(\.policiesResponse.success) {
    $0.isLoading = false
    $0.policies = [Policy.mock1, Policy.mock2]
  }
}
```

> **trailing closure의 의미**
> `await store.send(.task) { $0.isLoading = true }` 의 `{ ... }`는 *이 Action을 처리한 뒤 State가 이렇게 변했어야 한다*는 단언입니다. TestStore는 실제로 Reduce가 변경한 State와 비교해서 다르면 테스트 실패를 냅니다.

### 9.2 규칙

- 모든 Dependency는 **테스트에서 명시적으로 override**한다. unimplemented 호출이 나면 테스트 실패.
- `await store.send(...)`의 trailing closure에서 **State 변경을 정확히 기술**한다.
- 비동기 Effect 결과는 `await store.receive(\.액션)` 로 받는다.
- `store.exhaustivity = .off`는 **임시 디버깅용**. PR에 남기지 않는다.

### 9.3 권장 테스트 범위

- 사용자 입력 Action → State 변화
- Effect 응답 Action → State 변화 + 후속 Action
- Delegate Action → 부모의 처리
- 취소 가능한 Effect의 취소 동작

---

## 10. 상황별 가이드 (Cookbook)

자주 마주치는 시나리오에 어떤 TCA 기술을 골라야 하는지 정리한 절입니다.

### 10.1 "버튼을 눌렀을 때 시트를 띄우고 싶다"

→ 7.1 `@Presents + Destination enum`. 시트가 한 종류뿐이라도 미래에 다른 시트가 추가될 수 있으니 처음부터 `Destination` enum으로 시작하세요.

```swift
case .didTapAddButton:
  state.destination = .addSheet(AddMemoFeature.State())
  return .none
```

### 10.2 "리스트의 한 행을 누르면 상세 화면으로 푸시"

→ 7.2 `StackState + Path enum`. 시트가 아니라 *되돌아갈 수 있는 푸시*라면 스택이 맞습니다.

```swift
case .didTapRow(let id):
  guard let policy = state.policies[id: id] else { return .none }
  state.path.append(.detail(PolicyDetailFeature.State(policy: policy)))
  return .none
```

### 10.3 "상세 화면에서 삭제했더니 리스트가 갱신돼야 한다"

→ 3.3 `delegate Action`. 자식이 일을 끝낸 후 `delegate(.policyDeleted(id))`를 보내고, 부모는 path/destination을 통해 그것을 받아 처리.

```swift
// 부모
case .path(.element(_, .detail(.delegate(.policyDeleted(let id))))):
  state.policies.remove(id: id)
  return .none
```

### 10.4 "검색창에 글자를 칠 때마다 fetch가 일어나면 안 됨"

→ 5.2 `cancellable + cancelInFlight: true`. 디바운스 + 직전 요청 취소.

```swift
private enum CancelID { case search }

case .didChangeSearchText(let text):
  state.searchText = text
  return .run { send in
    try await clock.sleep(for: .milliseconds(300))
    do {
      let policies = try await policyClient.search(text)
      await send(.searchResponse(.success(policies)))
    } catch {
      await send(.searchResponse(.failure(error)))
    }
  }
  .cancellable(id: CancelID.search, cancelInFlight: true)
```

### 10.5 "화면에 들어왔을 때 데이터 불러오기"

→ View의 `.task { store.send(.task) }` + Reducer에서 `.run` Effect. `.task` 모디파이어는 View가 화면에 있는 동안만 살아 있어서, 사라지면 Effect가 자동 취소됩니다.

```swift
// View
var body: some View {
  content
    .task { store.send(.task) }
}

// Reducer
case .task:
  state.isLoading = true
  return .run { send in
    do {
      let policies = try await policyClient.fetchAll()
      await send(.policiesResponse(.success(policies)))
    } catch {
      await send(.policiesResponse(.failure(error)))
    }
  }
```

### 10.6 "한 화면 안에서 여러 입력 필드를 바인딩"

→ 8.4 `BindableAction + BindingReducer`. 필드마다 `didChange...` Action을 만드는 대신 `$store.foo`로 바로 바인딩.

### 10.7 "다른 Feature의 State를 봐야 한다"

→ **잘못된 신호**. 두 Feature가 같은 데이터를 본다면 *공통 부모*에서 그 데이터를 들고 자식들에게 전달하세요. 자식이 다른 자식의 State를 직접 import하는 일은 없어야 합니다.

### 10.8 "로딩 / 빈 / 결과 / 에러 네 가지를 화면에 그려야 한다"

→ 2.4 `LoadingState` enum. 네 가지를 분기 가능한 enum으로 모델링하면 View는 단순한 switch 한 번이면 됩니다.

---

## 11. 안티패턴 모음

| 안티패턴 | 왜 안 되나 | 대안 |
|---|---|---|
| State에 `class` 또는 `ObservableObject` | 값 의미 깨짐, 테스트 불가 | struct + computed |
| Reducer 안에서 `Task { ... }` | 취소·테스트 불가 | `.run { send in ... }` |
| Action 이름이 동사 (`loadPolicies`) | "해야 할 일"을 View가 결정하게 됨 | "일어난 일" (`didTapRefresh`) |
| 자식이 부모 State를 알고 변경 | 결합도 폭발 | `delegate(_)` Action |
| `default:` 케이스 | 새 Action 추가 시 누락 | exhaustive switch |
| `WithViewStore` 신규 사용 | Observation 시대엔 deprecated 패턴 | `@ObservableState` + `@Bindable` |
| View에서 `Task { }` | 라이프사이클·취소 깨짐 | `.task { store.send(...) }` + Reducer Effect |
| 싱글톤 직접 호출 | 테스트 불가, mock 불가 | `@Dependency` |
| `[Element]`로 행 관리 | ID 라우팅 불가 | `IdentifiedArrayOf<Element>` |
| State에 캐시된 파생값 저장 | 동기화 누락 위험 | computed property |

---

## 12. 리뷰 체크리스트 (AI 에이전트용)

> AI 에이전트는 PR 또는 Feature 코드 리뷰 요청 시 아래 항목을 **순서대로** 점검하고, 위반 사항을 항목 번호와 함께 보고한다. 각 항목은 **위반 / 통과 / 해당 없음** 중 하나로 판정한다.

### A. 파일 구조
- [ ] **A1.** Feature 디렉토리에 `{이름}Feature.swift`와 `{이름}View.swift`가 함께 있는가?
- [ ] **A2.** Reducer 타입 이름이 `~Feature` 형태인가? (`~ViewModel`, `~Store`, `~Reducer` 금지)

### B. State
- [ ] **B1.** State에 `@ObservableState`가 붙어 있는가?
- [ ] **B2.** State가 `Equatable`을 채택했는가?
- [ ] **B3.** State 프로퍼티가 모두 값타입인가? (class/ObservableObject 사용 금지)
- [ ] **B4.** 자식 컬렉션이 `IdentifiedArrayOf<...>`인가?
- [ ] **B5.** 파생 데이터가 computed property로 노출되는가? (저장 금지)
- [ ] **B6.** "로딩 전"과 "빈 결과"가 구분되는 모델링인가?

### C. Action
- [ ] **C1.** Action 이름이 "일어난 일"(이벤트형, 과거형)로 작성됐는가?
- [ ] **C2.** 부모에게 전달할 결과가 `delegate(_)` Action으로 분리됐는가?
- [ ] **C3.** 자식 Feature 결합이 `destination`/`path`/`{자식}` 형태로 일관되게 명명됐는가?
- [ ] **C4.** Action이 가능한 한 `Equatable`인가?
- [ ] **C5.** Action enum이 의미별 그룹(View/Internal/Child/Delegate)으로 정리됐는가?

### D. Reducer
- [ ] **D1.** `@Reducer` 매크로를 사용했는가?
- [ ] **D2.** `Reduce` 안의 `switch`가 **exhaustive**한가? (`default` 금지)
- [ ] **D3.** 각 case 본문이 5~10줄 이내인가? (초과 시 helper로 분리)
- [ ] **D4.** Reducer 안에서 `Task { ... }`를 직접 띄우지 않는가?
- [ ] **D5.** Reducer 안에서 `URLSession`, `Date()`, `UUID()`, 싱글톤을 직접 호출하지 않는가?
- [ ] **D6.** 자식 결합이 `Scope`/`ifLet`/`forEach` 중 적절한 것으로 됐는가?
- [ ] **D7.** Reducer가 View 표현(색·문자열) 결정을 하지 않는가?

### E. Effect
- [ ] **E1.** 비동기 작업이 전부 `.run { send in ... }`로 표현됐는가?
- [ ] **E2.** State 캡처가 캡처 리스트 `[x = state.x]`로 명시됐는가? (`state.x` 직접 참조 금지)
- [ ] **E3.** 디바운스·중복 방지가 필요한 Effect가 `cancellable(id:cancelInFlight:)`을 쓰는가?
- [ ] **E4.** 에러가 묵살되지 않고 응답 Action(`Result`)으로 돌아오는가?
- [ ] **E5.** `CancelID`가 Feature-private enum(취소 작업별 case)으로 정의됐는가?

### F. Dependency
- [ ] **F1.** 외부 호출이 모두 `@Dependency`로 주입됐는가?
- [ ] **F2.** Client가 `@DependencyClient`로 정의되고 `liveValue`/`testValue`/`previewValue`를 제공하는가?
- [ ] **F3.** `DependencyValues` extension으로 키가 등록됐는가?
- [ ] **F4.** Reducer/View에서 싱글톤(`.shared`) 직접 호출이 없는가?
- [ ] **F5.** `BaziPresentation`이 `BaziData`를 import하지 않는가? (Live 조립은 `ChungBazi` 앱 타겟에서만)

### G. Navigation
- [ ] **G1.** 0~1개 자식 화면이 `@Presents` + `ifLet`으로 구성됐는가?
- [ ] **G2.** 다중 화면 스택이 `StackState` + `forEach`로 구성됐는가?
- [ ] **G3.** 두 자식이 서로 통신할 때 공통 부모를 거치는가? (자식끼리 직접 연결 금지)
- [ ] **G4.** `@Reducer enum`(Path/Destination) 뒤에 `extension X.State: Equatable {}`이 있는가? (deprecated된 `(state: .equatable)` 사용 금지, 7.5절)

### H. View
- [ ] **H1.** View가 `let store` 또는 `@Bindable var store`로 Store를 보유하는가?
- [ ] **H2.** `WithViewStore`/`ViewStore`가 신규 코드에 사용되지 않았는가?
- [ ] **H3.** View가 직접 `Task { ... }`를 띄우지 않는가? (`.task { store.send(...) }` 사용)
- [ ] **H4.** View에서 `@Dependency`를 직접 읽지 않는가?
- [ ] **H5.** 바인딩이 `$store.프로퍼티` 또는 `BindingReducer` 패턴인가?
- [ ] **H6.** `var body`에 최상위 컨테이너 하나만 있고 하위뷰가 `private` extension으로 분리됐는가?

### I. Testing
- [ ] **I1.** Feature에 `TestStore` 기반 단위 테스트가 존재하는가?
- [ ] **I2.** 테스트에서 모든 Dependency가 명시적으로 override됐는가?
- [ ] **I3.** `store.exhaustivity = .off`가 코드에 남아 있지 않은가?
- [ ] **I4.** Delegate 동작에 대한 테스트가 있는가? (자식 → 부모 상호작용)

### J. 코드 스타일
- [ ] **J1.** [CODING_GUIDELINES.md](./CODING_GUIDELINES.md)의 규칙(접근 제어, MARK 구분, 임포트 순서)을 따르는가?
- [ ] **J2.** 강제 언래핑(`!`)이 없는가?
- [ ] **J3.** Action 이름이 [CODING_GUIDELINES.md §1](./CODING_GUIDELINES.md#1-네이밍)의 "이벤트 핸들러 과거형" 규칙과 일치하는가?

---

## 13. 리뷰 출력 형식 (AI 에이전트용)

리뷰 결과는 아래 형식으로 작성한다.

```text
## TCA Convention Review

### 🚨 Critical (반드시 수정)
- [D2] PolicyListFeature.swift:42 — switch에 default 케이스가 있음. 모든 Action을 명시적으로 처리해야 함.
- [E2] PolicyListFeature.swift:78 — .run 클로저 안에서 state.id를 직접 참조. 캡처 리스트로 옮길 것.

### ⚠️ Warning (개선 권장)
- [C1] Action `loadPolicies` — 명령형. `onAppear` 또는 `didTapRefreshButton`으로 변경 권장.
- [B5] State.filteredPolicies가 저장 프로퍼티. computed property로 변경.

### 💡 Suggestion (선택)
- [C5] Action enum이 그룹화되지 않음. View/Internal/Delegate 섹션으로 MARK 구분 권장.

### ✅ Passed
- @Reducer, @ObservableState 모두 적용
- TestStore 기반 테스트 존재 및 Dependency override 정상
```

각 지적에는 **항목 번호(`[D2]` 등)**, **파일:라인**, **위반 내용**, **수정 방향**을 포함한다.

---

## 관련 문서

- [CODING_GUIDELINES.md](./CODING_GUIDELINES.md) — 프로젝트 전반의 Swift/SwiftUI 코딩 컨벤션
