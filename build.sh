#!/usr/bin/env bash
#
# Quick Board — 스컬킹 Flutter 앱 빌드 스크립트
#
# 사용법:
#   ./build.sh                    # Android + iOS 스크린샷/테스트 빌드
#   ./build.sh android            # Android AAB/APK
#   ./build.sh ios                # iOS no-codesign
#   ./build.sh apk                # Android APK만
#   ./build.sh aab                # Android AAB만
#
# 출시 빌드:
#   ./build.sh android release    # 버전 입력 -> pubspec 갱신 -> Play 심사용 AAB 광고 ON 빌드
#   ./build.sh aab release        # 버전 입력 -> pubspec 갱신 -> Play 심사용 AAB 광고 ON 빌드
#   ./build.sh ios release        # 버전 입력 -> pubspec 갱신 -> App Store 심사용 IPA 광고 ON 빌드
#
# 환경 변수:
#   SHOW_ADMOB=true|false         # release 빌드는 기본 true, 그 외 빌드는 기본 false
#   AUTO_COMMIT=true|false        # release 빌드는 기본 true. pubspec 버전 변경만 커밋
#
set -uo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="$ROOT_DIR/quick-board-flutter/apps/skulking"
PUBSPEC="$APP_DIR/pubspec.yaml"
TARGET="${1:-all}"
BUILD_KIND="${2:-snapshot}"
FAIL=0
VERSION_UPDATED=0
NEXT_VERSION=""
RELEASE_OUTPUT_DIRS=()

export PATH="/Users/yee/Programs/flutter/bin:/opt/homebrew/bin:$PATH"

info() { printf "\033[1;34m[build]\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[build] ! %s\033[0m\n" "$*"; }
err()  { printf "\033[1;31m[build] x %s\033[0m\n" "$*"; }

command -v flutter >/dev/null 2>&1 || { err "flutter 명령을 찾을 수 없습니다"; exit 1; }
[ -d "$APP_DIR" ] || { err "앱 경로를 찾을 수 없습니다: $APP_DIR"; exit 1; }
[ -f "$PUBSPEC" ] || { err "pubspec.yaml을 찾을 수 없습니다: $PUBSPEC"; exit 1; }

case "$BUILD_KIND" in
  snapshot|release) ;;
  *) err "알 수 없는 빌드 옵션: $BUILD_KIND (snapshot | release)"; exit 1 ;;
esac

if [ -z "${SHOW_ADMOB+x}" ]; then
  if [ "$BUILD_KIND" = "release" ]; then
    SHOW_ADMOB="true"
  else
    SHOW_ADMOB="false"
  fi
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
  current="$(current_version_line)"
  current_name="$(version_name "$current")"
  current_build="$(version_build "$current")"
  [ -n "$current_name" ] || { err "현재 version 값을 읽을 수 없습니다"; exit 1; }
  [ -n "$current_build" ] || current_build=0

  info "현재 앱 버전: $current_name+$current_build"

  while true; do
    printf "출시 앱 버전 입력 (예: 1.0.0, 현재 %s): " "$current_name"
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

    printf "출시 빌드번호 입력 (현재 %s보다 큰 정수): " "$current_build"
    IFS= read -r next_build
    if ! valid_build_number "$next_build"; then
      warn "빌드번호는 1 이상의 정수여야 합니다."
      continue
    fi

    if [ "$next_build" -le "$current_build" ]; then
      warn "입력한 빌드번호($next_build)가 현재 빌드번호($current_build)보다 크지 않습니다."
      continue
    fi

    next_version="$next_name+$next_build"
    break
  done

  info "pubspec.yaml version 갱신: $current -> $next_version"
  perl -0pi -e "s/^version:\\s*\\S+/version: $next_version/m" "$PUBSPEC"
  VERSION_UPDATED=1
  NEXT_VERSION="$next_version"
}

commit_release_version() {
  [ "$BUILD_KIND" = "release" ] || return
  [ "$VERSION_UPDATED" -eq 1 ] || return
  [ "$AUTO_COMMIT" = "true" ] || { info "AUTO_COMMIT=false 이므로 커밋을 건너뜁니다."; return; }

  pubspec_rel="quick-board-flutter/apps/skulking/pubspec.yaml"
  if git -C "$ROOT_DIR" diff --quiet -- "$pubspec_rel"; then
    info "커밋할 pubspec version 변경이 없습니다."
    return
  fi

  info "출시 버전 변경 커밋: $NEXT_VERSION"
  if git -C "$ROOT_DIR" commit --only "$pubspec_rel" -m "chore: bump skulking to $NEXT_VERSION"; then
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
  [ -n "${ANDROID_HOME:-}" ] || [ -n "${ANDROID_SDK_ROOT:-}" ] || [ -d "$HOME/Library/Android/sdk" ]
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
  if flutter build appbundle --release "$dart_define"; then
    output_dir="$APP_DIR/build/app/outputs/bundle/release"
    info "AAB: $output_dir/app-release.aab"
    remember_release_output_dir "$output_dir"
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
  if flutter build apk --release "$dart_define"; then
    info "APK: $APP_DIR/build/app/outputs/flutter-apk/app-release.apk"
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

  if command -v pod >/dev/null 2>&1; then
    info "pod install"
    pod install --project-directory=ios || { err "pod install 실패"; FAIL=1; return; }
  else
    warn "CocoaPods가 없어 iOS 빌드가 실패할 수 있습니다."
  fi

  if [ "$BUILD_KIND" = "release" ]; then
    info "iOS App Store 심사용 IPA 빌드: SHOW_ADMOB=$SHOW_ADMOB"
    if flutter build ipa --release "$dart_define"; then
      output_dir="$APP_DIR/build/ios/ipa"
      info "IPA: $output_dir"
      remember_release_output_dir "$output_dir"
    else
      err "iOS IPA 빌드 실패"
      FAIL=1
    fi
  else
    info "iOS no-codesign 빌드: kind=$BUILD_KIND, SHOW_ADMOB=$SHOW_ADMOB"
    if flutter build ios --release --no-codesign "$dart_define"; then
      info "iOS app: $APP_DIR/build/ios/iphoneos/Skulking.app"
      info "심사용 IPA: ./build.sh ios release"
    else
      err "iOS 빌드 실패"
      FAIL=1
    fi
  fi
}

if [ "$BUILD_KIND" = "release" ]; then
  prompt_release_version
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
