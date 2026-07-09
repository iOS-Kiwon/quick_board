#!/usr/bin/env bash
#
# Quick Board — 스컬킹 Flutter 앱 실행 스크립트
#
# 사용법:
#   ./run.sh                    # 연결된 첫 기기에서 실행
#   ./run.sh android            # 첫 Android 기기/에뮬레이터
#   ./run.sh ios                # 첫 iOS 기기/시뮬레이터
#   ./run.sh all                # iOS + Android 동시 실행
#   ./run.sh <deviceId>         # 특정 기기 ID
#
# 환경 변수:
#   MODE=release|debug|profile  # 기본 release
#   SHOW_ADMOB=true|false       # 기본 true. 광고 없이 실행할 때 false
#
set -uo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="$ROOT_DIR/quick-board-flutter/apps/skulking"
MODE="${MODE:-release}"
TARGET="${1:-auto}"
SHOW_ADMOB="${SHOW_ADMOB:-true}"

export PATH="/Users/yee/Programs/flutter/bin:/opt/homebrew/bin:$PATH"

info() { printf "\033[1;34m[run]\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[run] ! %s\033[0m\n" "$*"; }
err()  { printf "\033[1;31m[run] x %s\033[0m\n" "$*"; }

command -v flutter >/dev/null 2>&1 || { err "flutter 명령을 찾을 수 없습니다"; exit 1; }
[ -d "$APP_DIR" ] || { err "앱 경로를 찾을 수 없습니다: $APP_DIR"; exit 1; }

cd "$APP_DIR" || exit 1

mode_flag() {
  case "$MODE" in
    debug|profile|release) printf -- "--%s" "$MODE" ;;
    *) err "알 수 없는 MODE: $MODE (debug | profile | release)"; exit 1 ;;
  esac
}

dart_defines() {
  if [ "$SHOW_ADMOB" = "true" ]; then
    printf -- "--dart-define=SHOW_ADMOB=true"
  else
    printf -- "--dart-define=SHOW_ADMOB=false"
  fi
}

pick_device() {
  flutter devices --machine 2>/dev/null | python3 -c '
import json
import sys

platform = sys.argv[1]
try:
    devices = json.load(sys.stdin)
except Exception:
    sys.exit(0)

for device in devices:
    target = str(device.get("targetPlatform", ""))
    if platform == "ios" and target.startswith("ios"):
        print(device["id"])
        break
    if platform == "android" and target.startswith("android"):
        print(device["id"])
        break
' "$1"
}

run_device() {
  device_id="$1"
  label="$2"
  info "$label 실행: mode=$MODE, SHOW_ADMOB=$SHOW_ADMOB, device=$device_id"
  flutter run "$(mode_flag)" "$(dart_defines)" -d "$device_id"
}

case "$TARGET" in
  auto)
    info "연결된 첫 기기에서 실행: mode=$MODE, SHOW_ADMOB=$SHOW_ADMOB"
    flutter run "$(mode_flag)" "$(dart_defines)"
    ;;
  ios|android)
    device="$(pick_device "$TARGET")"
    [ -n "$device" ] || { err "$TARGET 기기를 찾을 수 없습니다. flutter devices로 확인하세요."; exit 1; }
    run_device "$device" "$TARGET"
    ;;
  all)
    ios_device="$(pick_device ios)"
    android_device="$(pick_device android)"
    [ -n "${ios_device}${android_device}" ] || { err "실행할 iOS/Android 기기가 없습니다"; exit 1; }

    mkdir -p "$ROOT_DIR/build/run-logs"
    if [ -n "$ios_device" ]; then
      info "iOS 백그라운드 실행 -> build/run-logs/ios.log"
      nohup flutter run "$(mode_flag)" "$(dart_defines)" -d "$ios_device" >"$ROOT_DIR/build/run-logs/ios.log" 2>&1 &
    else
      warn "iOS 기기 없음"
    fi

    if [ -n "$android_device" ]; then
      info "Android 백그라운드 실행 -> build/run-logs/android.log"
      nohup flutter run "$(mode_flag)" "$(dart_defines)" -d "$android_device" >"$ROOT_DIR/build/run-logs/android.log" 2>&1 &
    else
      warn "Android 기기 없음"
    fi

    info "로그 확인: tail -f build/run-logs/*.log"
    ;;
  *)
    run_device "$TARGET" "지정 기기"
    ;;
esac
