# 빌드 & 실행 가이드 (Quick Board)

Quick Board 저장소 안의 Flutter 앱들을 실행/빌드하는 방법입니다.
`build.sh`와 `run.sh`는 실행하면 **가장 먼저 어떤 앱을 다룰지 물어봅니다.**

## 앱 목록

| | 스컬킹 점수계산 | 요트다이스 점수계산 |
|---|---|---|
| 앱 ID | `skulking` | `yacht` |
| 앱 경로 | `quick-board-flutter/apps/skulking` | `quick-board-flutter/apps/yacht` |
| 지원 플랫폼 | iOS, Android | **iOS 전용** |
| Bundle ID / applicationId | `com.quickboard.skulking` | `com.quickboard.yacht` |
| 출시 버전 파일 | `release_versions/android.txt`, `ios.txt` | `release_versions/ios.txt` |

`quick-board-flutter/apps/` 아래에 `pubspec.yaml`이 있는 폴더를 앱으로 인식합니다.
새 앱을 추가하면 두 스크립트의 선택 목록에 자동으로 나타납니다.

> 기본 빌드와 실행에서 AdMob이 켜집니다.
> 광고 없이 실행하거나 빌드하려면 `SHOW_ADMOB=false`를 사용하세요.

## 빠른 스크립트

저장소 루트에서 실행합니다. 앱을 지정하지 않으면 실행 직후 선택 목록이 나옵니다.

```bash
./build.sh
# [build] 어떤 앱을 빌드할까요?
#   1) 스컬킹 (skulking)
#   2) 요트다이스 (yacht)
# 앱 선택 [1-2]:
```

앱을 미리 정해두면 묻지 않습니다. 첫 인자나 `APP` 환경 변수 둘 다 됩니다.

```bash
./build.sh yacht ios release        # 첫 인자로 지정
APP=yacht ./build.sh ios release    # 환경 변수로 지정
```

### 빌드

```bash
./build.sh                       # 앱 선택 -> 스크린샷/테스트 빌드 (지원 플랫폼 전부)
./build.sh android               # 앱 선택 -> Android AAB/APK
./build.sh aab                   # 앱 선택 -> Android AAB만
./build.sh apk                   # 앱 선택 -> Android APK만
./build.sh ios                   # 앱 선택 -> iOS no-codesign

./build.sh skulking android release   # 심사 제출용: 버전 입력 -> Play AAB -> 버전 커밋
./build.sh skulking ios release       # 심사 제출용: 버전 입력 -> App Store IPA -> 버전 커밋
./build.sh yacht ios release          # 요트다이스 App Store IPA
```

### 실행

```bash
./run.sh                         # 앱 선택 -> 연결된 첫 기기
./run.sh android                 # 앱 선택 -> 첫 Android 기기/에뮬레이터
./run.sh ios                     # 앱 선택 -> 첫 iOS 기기/시뮬레이터
./run.sh all                     # 앱 선택 -> iOS + Android 동시 실행

./run.sh yacht ios               # 요트다이스를 첫 iOS 기기에서
./run.sh skulking R5CX937DAHV    # 특정 기기 ID로

MODE=debug ./run.sh yacht ios    # debug/profile/release 선택
SHOW_ADMOB=false ./run.sh yacht  # 광고 OFF로 실행
```

> **시뮬레이터에서는 `MODE=debug`가 필요합니다.**
> iOS 시뮬레이터와 Android 에뮬레이터는 AOT 컴파일을 지원하지 않아
> 기본값인 release 모드로 실행할 수 없습니다. 스크립트가 이 경우를 감지해
> 빌드 전에 안내하고 중단합니다.

> 요트다이스에 `android` 대상을 지정하면 스크립트가 iOS 전용 앱이라고 알리고 멈춥니다.
> `./run.sh yacht all`이나 `./build.sh yacht`처럼 전체 대상을 고르면
> 지원하는 플랫폼만 골라서 처리합니다.

## 사전 준비

```bash
flutter doctor
flutter devices
cd quick-board-flutter/apps/<앱>     # skulking 또는 yacht
flutter pub get
```

macOS에서 Flutter 명령이 안 잡히면 아래 경로 중 설치된 쪽을 PATH에 추가하세요.

```bash
export PATH="/opt/homebrew/bin:$PATH"
```

iOS 의존성은 Swift Package Manager로 관리합니다. CocoaPods는 쓰지 않으므로
`pod install`이 필요 없습니다. 패키지는 첫 빌드 때 Xcode가 내려받습니다.

## Android (스컬킹 전용)

요트다이스에는 `android` 폴더가 없습니다.

### 실행

```bash
cd quick-board-flutter/apps/skulking
flutter devices
flutter run --release -d "<device-id>"
```

### 빌드

```bash
cd quick-board-flutter/apps/skulking

# 기본 빌드: 광고 ON
flutter build apk --release
flutter build appbundle --release

# 광고 OFF 빌드
flutter build appbundle --release --dart-define=SHOW_ADMOB=false
```

산출물:

- APK: `quick-board-flutter/apps/skulking/build/app/outputs/flutter-apk/app-release.apk`
- AAB: `quick-board-flutter/apps/skulking/build/app/outputs/bundle/release/app-release.aab`

### 서명

release 서명은 `android/key.properties`와 `android/app/upload-keystore.jks`를 사용합니다.
두 파일 모두 gitignore 대상이라 저장소에 없습니다. 빌드하는 기기에 직접 두어야 합니다.
`./build.sh skulking android release`는 실행 전에 두 파일이 있는지 검사하고, 없으면 멈춥니다.

## iOS

### 실행

```bash
cd quick-board-flutter/apps/<앱>
flutter devices
flutter run --debug -d "<device-id>"      # 시뮬레이터는 debug만 가능
flutter run --release -d "<device-id>"    # 실기기
```

실기기 실행과 IPA 빌드에는 Xcode 서명 설정이 필요합니다.
Xcode → Settings → Accounts에 팀 `W6B6ZQQ57S` 권한이 있는 Apple ID를 추가한 뒤,
`Runner` 타깃의 Signing & Capabilities에서 Team과 프로비저닝 프로파일을 확인하세요.
Flutter가 빌드에 `.xcworkspace`를 쓰므로 Xcode에서도 이쪽을 여세요.

```bash
open quick-board-flutter/apps/yacht/ios/Yacht.xcworkspace
```

### 빌드 확인

```bash
cd quick-board-flutter/apps/<앱>
flutter build ios --release --no-codesign
```

스토어 업로드용 IPA는 Xcode 서명 설정 후 실행합니다.

```bash
./build.sh yacht ios release
```

### 의존성 관리 (Swift Package Manager)

두 앱 모두 CocoaPods를 걷어내고 SPM으로 옮겼습니다. `Podfile`, `Podfile.lock`, `Pods/`가
없고 `pod install`도 하지 않습니다. 패키지 버전은 아래 두 파일로 고정합니다.

- `ios/<앱>.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`
- `ios/<앱>.xcworkspace/xcshareddata/swiftpm/Package.resolved`

### Xcode에서 직접 빌드할 때

Xcode에서 고를 대상과 **다른 대상으로** flutter 명령을 먼저 돌리면 Xcode 빌드가 깨집니다.
`flutter run`을 iOS 17 이상 실기기에 debug로 돌리면 Flutter가
`ios/Flutter/Generated.xcconfig`에 그 대상의 산출물 경로를 `CONFIGURATION_BUILD_DIR`로
박아두기 때문입니다. 이 값은 빌드 구성과 무관하게 경로를 강제합니다.

그 상태로 Xcode에서 시뮬레이터를 빌드하면 실기기용 `Flutter.framework`를 찾다가
`import Flutter`를 하는 플러그인들이 줄줄이 실패합니다.

```
Unable to resolve module dependency: 'Flutter'
'Flutter/Flutter.h' file not found
```

Xcode로 빌드하기 전에 같은 대상으로 flutter 명령을 한 번 돌리면 됩니다.
저장소 루트가 아니라 **앱 폴더에서** 실행해야 합니다.

```bash
cd quick-board-flutter/apps/<앱>          # skulking 또는 yacht

flutter build ios --debug --simulator     # Xcode에서 시뮬레이터를 빌드할 때
flutter build ios --debug --no-codesign   # Xcode에서 실기기를 빌드할 때
```

## 출시 빌드 버전 입력

`./build.sh <앱> <대상> release` 형식으로 실행하면 스토어 심사 제출용 산출물을 만듭니다.
스크립트가 플랫폼별 release version 파일을 읽고 새 앱 버전과 빌드번호를 묻습니다.

```bash
./build.sh skulking aab release      # Google Play Console 업로드용 AAB
./build.sh skulking ios release      # App Store Connect 업로드용 IPA
./build.sh yacht ios release         # App Store Connect 업로드용 IPA
```

규칙:

- 앱마다, 그리고 Android와 iOS마다 서로 다른 앱 버전/빌드번호를 사용할 수 있습니다.
- 앱 버전은 해당 플랫폼의 현재 버전보다 낮을 수 없습니다.
- 빌드번호는 해당 플랫폼의 현재 빌드번호보다 낮을 수 없습니다.
- 앱 버전과 빌드번호가 모두 현재 값과 같으면, 동일한 값으로 빌드할지 확인합니다.
- `release_versions/` 폴더가 없으면 처음 release 빌드할 때 만들어집니다. 이때는 `pubspec.yaml`의 version을 현재 값으로 봅니다.
- 정상 입력이면 `release_versions/android.txt` 또는 `ios.txt`가 갱신됩니다.
- 빌드에는 플랫폼별 값을 `--build-name`, `--build-number`로 전달합니다.
- Android release는 APK가 아니라 AAB만 생성합니다.
- iOS release는 no-codesign 앱이 아니라 IPA를 생성합니다.
- release 빌드가 성공하면 생성된 AAB/IPA 폴더를 Finder로 엽니다.
- 빌드가 성공하면 해당 앱의 release version 파일 변경만 자동 커밋합니다.
- 자동 커밋을 끄려면 `AUTO_COMMIT=false ./build.sh yacht ios release`를 사용합니다.

> `flutter run`은 `--build-name`, `--build-number`를 받지 않습니다.
> 출시 버전은 `build.sh`에서만 쓰이고, `run.sh`는 개발 실행이라 버전을 붙이지 않습니다.

## AdMob 토글

각 앱의 `lib/main.dart`에서 `SHOW_ADMOB` dart-define을 읽습니다.

- 기본값: 광고 ON
- 광고 OFF: `--dart-define=SHOW_ADMOB=false`

스크린샷용으로 광고를 숨기려면 `SHOW_ADMOB=false`를 지정합니다.

광고 배너는 두 앱 모두 `MaterialApp.router`의 `builder`에서 Navigator보다 위에 한 번만
배치됩니다. 화면을 이동해도 배너가 다시 로드되지 않고, 위치는 화면 상단(세이프 영역 바로
아래)입니다. 모든 화면이 값을 입력하는 화면이라 하단에 두면 키패드에 가려집니다.

## Firebase

Firebase 설정 파일 위치:

- 스컬킹 Android: `quick-board-flutter/apps/skulking/android/app/google-services.json`
- 스컬킹 iOS: `quick-board-flutter/apps/skulking/ios/Runner/GoogleService-Info.plist`
- 요트다이스 iOS: `quick-board-flutter/apps/yacht/ios/Runner/GoogleService-Info.plist`

Android는 Google Services Gradle 플러그인을 사용합니다.
iOS는 Dart 패키지 없이 네이티브만 씁니다. Xcode 프로젝트에 firebase-ios-sdk를
Swift Package로 붙이고 `FirebaseAnalytics` 제품을 앱 타깃에 링크한 뒤,
`AppDelegate.swift`에서 `FirebaseApp.configure()`를 호출합니다.

## 스플래시와 앱 아이콘 (스컬킹 Android)

Android 앱 아이콘:

- `quick-board-flutter/apps/skulking/android/app/src/main/res/mipmap-*/ic_launcher.png`
- Android 8+ adaptive icon:
  - `quick-board-flutter/apps/skulking/android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml`
  - `quick-board-flutter/apps/skulking/android/app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml`

스플래시 배경색:

- `quick-board-flutter/apps/skulking/android/app/src/main/res/values/colors.xml`
- 색상: `#1B1406`

## 유용한 명령

```bash
cd quick-board-flutter/apps/<앱>
flutter clean
flutter pub get
flutter analyze
flutter test
```
