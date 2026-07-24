# Route Reference (참고용, 빌드 대상 아님)

TCA 도입 전 `Coordinator/Routes/`에 있던 Route enum들입니다. `Sources/` 밖에 있어 Tuist 빌드에 포함되지 않습니다 — 코드가 아니라 **케이스 목록 참고 자료**입니다.

각 Feature의 `Destination`/`Path` enum을 설계할 때, 여기 있는 케이스 이름과 대응 관계를 참고하세요.

| 원래 Route | 대응하는 TCA 구조 |
|---|---|
| `HomeRoute` | `HomeFeature.Path`의 케이스들 (`categoryPolicyList`, `popularPolicyList`, `deadlinePolicyList`, `newPolicyList`, `notification`) |
| `SearchRoute` | `SearchFeature.Path` |
| `MyPolicyRoute` | `MyPolicyFeature.Path` |
| `ProfileRoute` | `ProfileFeature.Path` |
| `OnboardingRoute` | `OnboardingFeature.Path` (`policyInterestSetup`, `onboardingComplete`) |
| `SharedRoute` | 여러 탭이 공유하는 화면. 각 탭의 `Path`가 개별적으로 참조하거나, 공용 자식 Feature로 분리 |
| `ModalRoute` | 그 화면을 띄우는 상위 Feature의 `@Presents var destination: Destination.State?` (`webView`, `calendarPolicyList`) |

Feature를 실제로 구현하면서 해당 Route의 대응 케이스를 다 옮겼다면, 그 Route 파일은 지워도 됩니다.
