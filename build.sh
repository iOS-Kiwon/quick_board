#!/usr/bin/env bash
#
# Quick Board — Flutter 앱 빌드 스크립트
#
set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APPS_DIR="$ROOT_DIR/quick-board-flutter/apps"

export PATH="/Users/yee/Programs/flutter/bin:/opt/homebrew/bin:$PATH"

info() { printf "\033[1;34m[build]\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[build] ! %s\033[0m\n" "$*"; }
err()  { printf "\033[1;31m[build] x %s\033[0m\n" "$*"; }

usage() {
  cat <<'EOF'
Quick Board — Flutter 앱 빌드 스크립트

사용법:
  ./build.sh --help                도움말
  ./build.sh                       앱을 고른 뒤 Android + iOS 스크린샷/테스트 빌드
  ./build.sh <대상> [종류]         앱을 물어본 뒤 빌드
  ./build.sh <앱> <대상> [종류]    앱까지 인자로 지정 (프롬프트 생략)

앱:
  skulking | yacht                 생략하면 실행할 때 물어봅니다

대상:
  all (기본) | android | aab | apk | ios

종류:
  snapshot (기본) | release

예:
  ./build.sh                       앱을 고른 뒤 스냅샷 빌드
  ./build.sh ios release           앱을 고른 뒤 App Store 심사용 IPA
  ./build.sh yacht ios release     요트다이스 App Store 심사용 IPA
  APP=yacht ./build.sh ios release 위와 같음

환경 변수:
  APP=skulking|yacht               앱 선택. 지정하면 묻지 않습니다
  SHOW_ADMOB=true|false            기본 true. 광고 없는 빌드가 필요하면 false
  AUTO_COMMIT=true|false           release 빌드는 기본 true. 플랫폼별 출시 버전 파일만 커밋
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

command -v flutter >/dev/null 2>&1 || { err "flutter 명령을 찾을 수 없습니다"; exit 1; }

# ---------------------------------------------------------------------------
# 어떤 앱을 빌드할지 가장 먼저 정한다.
# 순서: APP 환경변수 -> 첫 인자 -> 대화형 선택
# ---------------------------------------------------------------------------

app_exists() { [ -f "$APPS_DIR/$1/pubspec.yaml" ]; }

app_label() {
  case "$1" in
    skulking) printf "스컬킹" ;;
    yacht)    printf "요트다이스" ;;
    *)        printf "%s" "$1" ;;
  esac
}

list_apps() {
  for dir in "$APPS_DIR"/*/; do
    name="$(basename "$dir")"
    app_exists "$name" && printf "%s\n" "$name"
  done
}

prompt_app() {
  local apps=() choice i
  while IFS= read -r name; do apps+=("$name"); done < <(list_apps)
  [ "${#apps[@]}" -gt 0 ] || { err "빌드할 앱을 찾을 수 없습니다: $APPS_DIR"; exit 1; }

  if [ "${#apps[@]}" -eq 1 ]; then
    APP="${apps[0]}"
    return
  fi

  info "어떤 앱을 빌드할까요?"
  for i in "${!apps[@]}"; do
    printf "  %d) %s (%s)\n" "$((i + 1))" "$(app_label "${apps[$i]}")" "${apps[$i]}"
  done

  while true; do
    printf "앱 선택 [1-%d]: " "${#apps[@]}"
    IFS= read -r choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#apps[@]}" ]; then
      APP="${apps[$((choice - 1))]}"
      return
    fi
    warn "1부터 ${#apps[@]} 사이의 숫자를 입력하세요."
  done
}

APP="${APP:-}"
if [ -n "$APP" ]; then
  app_exists "$APP" || { err "알 수 없는 앱: $APP (가능: $(list_apps | tr '\n' ' '))"; exit 1; }
elif [ -n "${1:-}" ] && app_exists "$1"; then
  APP="$1"
  shift
elif [ -t 0 ]; then
  prompt_app
else
  err "앱을 지정하세요. 예: APP=yacht ./build.sh ios release"
  exit 1
fi

info "대상 앱: $(app_label "$APP") ($APP)"

APP_DIR="$APPS_DIR/$APP"
PUBSPEC="$APP_DIR/pubspec.yaml"
VERSION_DIR="$APP_DIR/release_versions"
TARGET="${1:-all}"
BUILD_KIND="${2:-snapshot}"
FAIL=0
RELEASE_OUTPUT_DIRS=()
RELEASE_VERSION_FILES=()
ANDROID_BUILD_NAME=""
ANDROID_BUILD_NUMBER=""
IOS_BUILD_NAME=""
IOS_BUILD_NUMBER=""
ANDROID_PENDING_VERSION=""
IOS_PENDING_VERSION=""
ANDROID_KEY_PROPERTIES="$APP_DIR/android/key.properties"
ANDROID_KEYSTORE="$APP_DIR/android/app/upload-keystore.jks"

[ -d "$APP_DIR" ] || { err "앱 경로를 찾을 수 없습니다: $APP_DIR"; exit 1; }
[ -f "$PUBSPEC" ] || { err "pubspec.yaml을 찾을 수 없습니다: $PUBSPEC"; exit 1; }

case "$BUILD_KIND" in
  snapshot|release) ;;
  *) err "알 수 없는 빌드 옵션: $BUILD_KIND (snapshot | release)"; exit 1 ;;
esac

if [ -z "${SHOW_ADMOB+x}" ]; then
  SHOW_ADMOB="true"
fi

if [ -z "${AUTO_COMMIT+x}" ]; then
  if [ "$BUILD_KIND" = "release" ]; then
    AUTO_COMMIT="true"
  else
    AUTO_COMMIT="false"
  fi
fi

dart_define="--dart-define=SHOW_ADMOB=false"
if [ "$SHOW_ADMOB" = "true" ]; then
  dart_define="--dart-define=SHOW_ADMOB=true"
fi

cd "$APP_DIR" || exit 1

current_version_line() {
  awk '/^version:/ {print $2; exit}' "$PUBSPEC"
}

platform_version_file() {
  case "$1" in
    android) printf "%s/android.txt" "$VERSION_DIR" ;;
    ios) printf "%s/ios.txt" "$VERSION_DIR" ;;
    *) err "알 수 없는 플랫폼: $1"; exit 1 ;;
  esac
}

current_platform_version_line() {
  file="$(platform_version_file "$1")"
  if [ -f "$file" ]; then
    awk 'NF {print $1; exit}' "$file"
  else
    current_version_line
  fi
}

version_name() {
  printf "%s" "$1" | cut -d+ -f1
}

version_build() {
  printf "%s" "$1" | cut -s -d+ -f2
}

valid_version_name() {
  printf "%s" "$1" | grep -Eq '^[0-9]+(\.[0-9]+){2,3}$'
}

valid_build_number() {
  printf "%s" "$1" | grep -Eq '^[1-9][0-9]*$'
}

compare_versions() {
  old="$1"
  new="$2"
  awk -v old="$old" -v new="$new" '
    function splitv(v, a) {
      n = split(v, raw, ".")
      for (i = 1; i <= 4; i++) a[i] = i <= n ? raw[i] + 0 : 0
    }
    BEGIN {
      splitv(old, o)
      splitv(new, n)
      for (i = 1; i <= 4; i++) {
        if (n[i] < o[i]) { print -1; exit }
        if (n[i] > o[i]) { print 1; exit }
      }
      print 0
    }
  '
}

prompt_release_version() {
  platform="$1"
  file="$(platform_version_file "$platform")"
  current="$(current_platform_version_line "$platform")"
  current_name="$(version_name "$current")"
  current_build="$(version_build "$current")"
  [ -n "$current_name" ] || { err "현재 version 값을 읽을 수 없습니다"; exit 1; }
  [ -n "$current_build" ] || current_build=0

  info "현재 $platform 앱 버전: $current_name+$current_build"

  while true; do
    printf "%s 출시 앱 버전 입력 (예: 1.0.0, 현재 %s): " "$platform" "$current_name"
    IFS= read -r next_name
    if ! valid_version_name "$next_name"; then
      warn "버전 형식이 올바르지 않습니다. 예: 1.0.0"
      continue
    fi

    version_cmp="$(compare_versions "$current_name" "$next_name")"
    if [ "$version_cmp" -lt 0 ]; then
      warn "입력한 앱 버전($next_name)이 현재 버전($current_name)보다 낮습니다."
      continue
    fi

    printf "%s 출시 빌드번호 입력 (현재 %s, 1 이상의 정수): " "$platform" "$current_build"
    IFS= read -r next_build
    if ! valid_build_number "$next_build"; then
      warn "빌드번호는 1 이상의 정수여야 합니다."
      continue
    fi

    if [ "$next_build" -lt "$current_build" ]; then
      warn "입력한 빌드번호($next_build)가 현재 빌드번호($current_build)보다 낮습니다."
      continue
    fi

    if [ "$version_cmp" -eq 0 ] && [ "$next_build" -eq "$current_build" ]; then
      while true; do
        printf "입력한 %s 버전이 현재와 동일합니다 (%s+%s). 이 값으로 빌드할까요? [y/N]: " "$platform" "$next_name" "$next_build"
        IFS= read -r answer
        case "$answer" in
          y|Y|yes|YES|Yes)
            next_version="$next_name+$next_build"
            break 2
            ;;
          n|N|no|NO|No|"")
            warn "동일한 버전 입력을 취소했습니다. 다시 입력하세요."
            continue 2
            ;;
          *)
            warn "y 또는 n으로 입력하세요."
            ;;
        esac
      done
    fi

    next_version="$next_name+$next_build"
    break
  done

  case "$platform" in
    android) ANDROID_PENDING_VERSION="$next_version" ;;
    ios) IOS_PENDING_VERSION="$next_version" ;;
  esac
  info "$platform release version 예약: $current -> $next_version (빌드 성공 후 저장)"
  RELEASE_VERSION_FILES+=("$file")

  case "$platform" in
    android)
      ANDROID_BUILD_NAME="$next_name"
      ANDROID_BUILD_NUMBER="$next_build"
      ;;
    ios)
      IOS_BUILD_NAME="$next_name"
      IOS_BUILD_NUMBER="$next_build"
      ;;
  esac
}

persist_release_version() {
  platform="$1"
  file="$(platform_version_file "$platform")"
  case "$platform" in
    android) version="$ANDROID_PENDING_VERSION" ;;
    ios) version="$IOS_PENDING_VERSION" ;;
    *) return 0 ;;
  esac
  [ -n "$version" ] || return 0

  mkdir -p "$VERSION_DIR"
  temp_file="$(mktemp "${file}.tmp.XXXXXX")" || {
    err "release version 임시 파일을 만들 수 없습니다: $file"
    return 1
  }
  if ! printf "%s\n" "$version" > "$temp_file" || ! mv "$temp_file" "$file"; then
    rm -f "$temp_file"
    err "release version 저장 실패: $file"
    return 1
  fi
  info "$file 저장 완료: $version"
}

commit_release_version() {
  [ "$BUILD_KIND" = "release" ] || return
  [ "${#RELEASE_VERSION_FILES[@]}" -gt 0 ] || return
  [ "$AUTO_COMMIT" = "true" ] || { info "AUTO_COMMIT=false 이므로 커밋을 건너뜁니다."; return; }

  rel_files=()
  changed_files=()
  for file in "${RELEASE_VERSION_FILES[@]}"; do
    rel="${file#$ROOT_DIR/}"
    rel_files+=("$rel")
    if ! git -C "$ROOT_DIR" diff --quiet -- "$rel"; then
      changed_files+=("$rel")
    elif ! git -C "$ROOT_DIR" ls-files --error-unmatch "$rel" >/dev/null 2>&1; then
      changed_files+=("$rel")
    fi
  done

  [ "${#changed_files[@]}" -gt 0 ] || { info "커밋할 release version 변경이 없습니다."; return; }

  info "플랫폼별 출시 버전 변경 커밋"
  if git -C "$ROOT_DIR" add "${rel_files[@]}" &&
     git -C "$ROOT_DIR" commit --only "${rel_files[@]}" -m "chore: bump $APP release versions"; then
    info "버전 커밋 완료"
  else
    err "버전 커밋 실패"
    FAIL=1
  fi
}

remember_release_output_dir() {
  [ "$BUILD_KIND" = "release" ] || return
  RELEASE_OUTPUT_DIRS+=("$1")
}

open_release_outputs() {
  [ "$BUILD_KIND" = "release" ] || return
  [ "${#RELEASE_OUTPUT_DIRS[@]}" -gt 0 ] || return

  if [ "$(uname)" != "Darwin" ] || ! command -v open >/dev/null 2>&1; then
    warn "Finder를 열 수 없는 환경입니다. 산출물 위치:"
    for dir in "${RELEASE_OUTPUT_DIRS[@]}"; do
      info "$dir"
    done
    return
  fi

  for dir in "${RELEASE_OUTPUT_DIRS[@]}"; do
    if [ -d "$dir" ]; then
      info "Finder 열기: $dir"
      open "$dir"
    fi
  done
}

have_android() {
  # 앱에 android 폴더가 없으면(iOS 전용 앱) Android 빌드 자체가 불가능하다.
  [ -d "$APP_DIR/android" ] || return 1
  [ -n "${ANDROID_HOME:-}" ] || [ -n "${ANDROID_SDK_ROOT:-}" ] || [ -d "$HOME/Library/Android/sdk" ]
}

# 명시적으로 고른 대상을 이 앱이 지원하는지 먼저 확인한다.
# all 은 지원하는 플랫폼만 골라 빌드하므로 검사하지 않는다.
require_platform_support() {
  case "$TARGET" in
    android|aab|apk|appbundle)
      [ -d "$APP_DIR/android" ] || {
        err "$(app_label "$APP")에는 android 폴더가 없습니다. iOS 전용 앱입니다."
        exit 1
      }
      ;;
    ios)
      [ -d "$APP_DIR/ios" ] || {
        err "$(app_label "$APP")에는 ios 폴더가 없습니다."
        exit 1
      }
      ;;
  esac
}

# 빌드된 .app 이름은 Xcode 프로젝트 이름을 따른다 (Skulking.xcodeproj -> Skulking.app)
ios_app_name() {
  local proj
  for proj in "$APP_DIR"/ios/*.xcodeproj; do
    [ -d "$proj" ] || continue
    basename "$proj" .xcodeproj
    return
  done
  printf "Runner"
}

require_android_release_signing() {
  [ "$BUILD_KIND" = "release" ] || return
  case "$TARGET" in
    all|android|aab|apk|appbundle) ;;
    *) return ;;
  esac
  # iOS 전용 앱은 Android 서명 설정이 필요 없다.
  [ -d "$APP_DIR/android" ] || return

  [ -f "$ANDROID_KEY_PROPERTIES" ] || {
    err "Android release 서명 설정이 없습니다: $ANDROID_KEY_PROPERTIES"
    exit 1
  }
  [ -f "$ANDROID_KEYSTORE" ] || {
    err "Android release 업로드 키가 없습니다: $ANDROID_KEYSTORE"
    exit 1
  }
}

run_pub_get() {
  info "flutter pub get"
  flutter pub get || { err "pub get 실패"; exit 1; }
}

build_aab() {
  if ! have_android; then
    warn "Android SDK를 찾을 수 없어 AAB 빌드를 건너뜁니다."
    return
  fi

  info "Android AAB 빌드: kind=$BUILD_KIND, SHOW_ADMOB=$SHOW_ADMOB"
  build_args=("$dart_define")
  if [ "$BUILD_KIND" = "release" ]; then
    build_args+=("--build-name=$ANDROID_BUILD_NAME" "--build-number=$ANDROID_BUILD_NUMBER")
  fi

  if flutter build appbundle --release "${build_args[@]}"; then
    output_dir="$APP_DIR/build/app/outputs/bundle/release"
    info "AAB: $output_dir/app-release.aab"
    remember_release_output_dir "$output_dir"
    if [ "$BUILD_KIND" = "release" ]; then
      persist_release_version android || FAIL=1
    fi
  else
    err "Android AAB 빌드 실패"
    FAIL=1
  fi
}

build_apk() {
  if ! have_android; then
    warn "Android SDK를 찾을 수 없어 APK 빌드를 건너뜁니다."
    return
  fi

  info "Android APK 빌드: kind=$BUILD_KIND, SHOW_ADMOB=$SHOW_ADMOB"
  build_args=("$dart_define")
  if [ "$BUILD_KIND" = "release" ]; then
    build_args+=("--build-name=$ANDROID_BUILD_NAME" "--build-number=$ANDROID_BUILD_NUMBER")
  fi

  if flutter build apk --release "${build_args[@]}"; then
    info "APK: $APP_DIR/build/app/outputs/flutter-apk/app-release.apk"
    if [ "$BUILD_KIND" = "release" ]; then
      persist_release_version android || FAIL=1
    fi
  else
    err "Android APK 빌드 실패"
    FAIL=1
  fi
}

build_ios() {
  if [ "$(uname)" != "Darwin" ]; then
    warn "iOS 빌드는 macOS에서만 가능합니다."
    return
  fi

  # CocoaPods를 걷어내고 Swift Package Manager로 옮겼으므로 pod install을 하지 않는다.
  # Podfile이 있는 프로젝트라면 flutter가 빌드 과정에서 알아서 pod install을 돌린다.

  if [ "$BUILD_KIND" = "release" ]; then
    info "iOS App Store 심사용 IPA 빌드: SHOW_ADMOB=$SHOW_ADMOB"
    build_args=("$dart_define" "--build-name=$IOS_BUILD_NAME" "--build-number=$IOS_BUILD_NUMBER")
    if flutter build ipa --release "${build_args[@]}"; then
      output_dir="$APP_DIR/build/ios/ipa"
      info "IPA: $output_dir"
      remember_release_output_dir "$output_dir"
      persist_release_version ios || FAIL=1
    else
      err "iOS IPA 빌드 실패"
      FAIL=1
    fi
  else
    info "iOS no-codesign 빌드: kind=$BUILD_KIND, SHOW_ADMOB=$SHOW_ADMOB"
    if flutter build ios --release --no-codesign "$dart_define"; then
      info "iOS app: $APP_DIR/build/ios/iphoneos/$(ios_app_name).app"
      info "심사용 IPA: ./build.sh $APP ios release"
    else
      err "iOS 빌드 실패"
      FAIL=1
    fi
  fi
}

require_platform_support
require_android_release_signing

if [ "$BUILD_KIND" = "release" ]; then
  case "$TARGET" in
    all)
      # 앱이 지원하는 플랫폼의 버전만 묻는다.
      [ -d "$APP_DIR/android" ] && prompt_release_version android
      [ -d "$APP_DIR/ios" ] && prompt_release_version ios
      ;;
    android|aab|apk|appbundle)
      prompt_release_version android
      ;;
    ios)
      prompt_release_version ios
      ;;
    *) err "알 수 없는 대상: $TARGET (all | android | apk | aab | ios)"; exit 1 ;;
  esac
fi

run_pub_get

case "$TARGET" in
  all)
    if [ "$BUILD_KIND" = "release" ]; then
      build_aab
      build_ios
    else
      build_aab
      build_apk
      build_ios
    fi
    ;;
  android)
    if [ "$BUILD_KIND" = "release" ]; then
      build_aab
    else
      build_aab
      build_apk
    fi
    ;;
  apk)       build_apk ;;
  aab)       build_aab ;;
  appbundle) warn "'appbundle' 대신 'aab'를 사용하세요."; build_aab ;;
  ios)       build_ios ;;
  *)         err "알 수 없는 대상: $TARGET (all | android | apk | aab | ios)"; exit 1 ;;
esac

if [ "$FAIL" -eq 0 ]; then
  info "빌드 완료"
  commit_release_version
  if [ "$FAIL" -ne 0 ]; then
    exit 1
  fi
  open_release_outputs
else
  err "일부 빌드에 실패했습니다."
  exit 1
fi
