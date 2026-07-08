# 빌드 & 실행 가이드 (Quick Board / 스컬킹)

Quick Board 저장소 안의 **스컬킹 점수계산** Flutter 앱을 iOS·Android에서 실행/빌드하는 방법입니다.

- 앱 경로: `quick-board-flutter/apps/skulking`
- Android applicationId: `com.quickboard.skulking`
- iOS Bundle Identifier: `com.quickboard.skulking`
- Flutter 버전 정보: `quick-board-flutter/apps/skulking/pubspec.yaml`

> 스토어 스크린샷을 찍기 쉽도록 기본 빌드에서는 AdMob이 꺼져 있습니다.
> 광고를 켠 출시 빌드는 `--dart-define=SHOW_ADMOB=true`를 사용하세요.

## 빠른 스크립트

저장소 루트에서 실행합니다.

```bash
./build.sh                  # Android AAB/APK + iOS no-codesign 스크린샷/테스트 빌드
./build.sh android          # Android AAB/APK 빌드
./build.sh aab              # Android AAB만 빌드
./build.sh apk              # Android APK만 빌드
./build.sh ios              # iOS no-codesign 빌드

./build.sh android release  # 심사 제출용: 버전 입력 -> Play AAB 광고 ON 빌드 -> 버전 커밋
./build.sh aab release      # 심사 제출용: 버전 입력 -> Play AAB 광고 ON 빌드 -> 버전 커밋
./build.sh ios release      # 심사 제출용: 버전 입력 -> App Store IPA 광고 ON 빌드 -> 버전 커밋

./run.sh                    # 연결된 첫 기기에서 release 실행
./run.sh android            # 첫 Android 기기/에뮬레이터에서 실행
./run.sh ios                # 첫 iOS 기기/시뮬레이터에서 실행
./run.sh R5CX937DAHV        # 특정 기기 ID로 실행
MODE=debug ./run.sh android # debug/profile/release 선택
SHOW_ADMOB=true ./run.sh android     # 광고 ON으로 실행
```

## 사전 준비

```bash
flutter doctor
flutter devices
cd quick-board-flutter/apps/skulking
flutter pub get
```

macOS에서 Flutter 명령이 안 잡히면 아래 경로 중 설치된 쪽을 PATH에 추가하세요.

```bash
export PATH="/Users/yee/Programs/flutter/bin:/opt/homebrew/bin:$PATH"
```

## Android

### 실행

```bash
cd quick-board-flutter/apps/skulking
flutter devices
flutter run --release -d "<device-id>"
```

현재 자주 쓰는 Android 단말 예:

```bash
flutter install -d R5CX937DAHV
```

### 빌드

```bash
cd quick-board-flutter/apps/skulking

# 스크린샷/테스트용: 광고 OFF
flutter build apk --release
flutter build appbundle --release

# 출시/심사용: 광고 ON
flutter build appbundle --release --dart-define=SHOW_ADMOB=true
```

산출물:

- APK: `quick-board-flutter/apps/skulking/build/app/outputs/flutter-apk/app-release.apk`
- AAB: `quick-board-flutter/apps/skulking/build/app/outputs/bundle/release/app-release.aab`

> 현재 Android release 빌드는 `android/app/build.gradle.kts`에서 debug signingConfig를 사용합니다.
> Play Console 정식 업로드 전에는 release keystore와 `android/key.properties` 기반 서명 설정으로 바꿔야 합니다.

## iOS

### 실행

```bash
cd quick-board-flutter/apps/skulking
flutter devices
flutter run --release -d "<device-id>"
```

실기기 실행은 Xcode의 Signing & Capabilities에서 Team 설정이 필요합니다.

### 빌드 확인

```bash
cd quick-board-flutter/apps/skulking
pod install --project-directory=ios
flutter build ios --release --no-codesign
```

스토어 업로드용 IPA는 Xcode 서명 설정 후 실행합니다.

```bash
./build.sh ios release
```

## 출시 빌드 버전 입력

`./build.sh <target> release` 형식으로 실행하면 스토어 심사 제출용 산출물을 만듭니다.
스크립트가 현재 `pubspec.yaml`의 `version`을 읽고 새 앱 버전과 빌드번호를 묻습니다.

예:

```bash
./build.sh aab release      # Google Play Console 업로드용 AAB
./build.sh android release  # Google Play Console 업로드용 AAB
./build.sh ios release      # App Store Connect 업로드용 IPA
```

규칙:

- 앱 버전은 현재 버전보다 낮을 수 없습니다.
- 빌드번호는 현재 빌드번호보다 낮을 수 없습니다.
- 앱 버전과 빌드번호가 모두 현재와 같으면, 동일한 값으로 빌드할지 확인합니다.
- 정상 입력이면 `quick-board-flutter/apps/skulking/pubspec.yaml`의 `version:`이 갱신됩니다.
- Android release는 APK가 아니라 AAB만 생성합니다.
- iOS release는 no-codesign 앱이 아니라 IPA를 생성합니다.
- release 빌드가 성공하면 생성된 AAB/IPA 폴더를 Finder로 엽니다.
- 빌드가 성공하면 `pubspec.yaml` 버전 변경만 자동 커밋합니다.
- 자동 커밋을 끄려면 `AUTO_COMMIT=false ./build.sh aab release`를 사용합니다.

## AdMob 토글

[main.dart](quick-board-flutter/apps/skulking/lib/main.dart)에서 `SHOW_ADMOB` dart-define을 읽습니다.

- 기본값: 광고 OFF
- 출시용 광고 ON: `--dart-define=SHOW_ADMOB=true`

스크린샷용 빌드에서는 아무 옵션도 주지 않으면 광고가 나오지 않습니다.

## Firebase

Firebase 설정 파일 위치:

- Android: `quick-board-flutter/apps/skulking/android/app/google-services.json`
- iOS: `quick-board-flutter/apps/skulking/ios/Runner/GoogleService-Info.plist`

Android는 Google Services Gradle 플러그인을 사용합니다.
iOS는 현재 Flutter/CocoaPods 플러그인 구성에 맞춰 `FirebaseAnalytics`를 CocoaPods로 설치합니다.

## 스플래시와 앱 아이콘

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
cd quick-board-flutter/apps/skulking
flutter clean
flutter pub get
flutter analyze
flutter test
```
