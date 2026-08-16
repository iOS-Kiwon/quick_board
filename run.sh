#!/usr/bin/env bash
#
# Quick Board — 스컬킹 Flutter 앱 실행 스크립트
#
# 사용법:
#   ./run.sh --help             # 도움말
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

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$ROOT_DIR/quick-board-flutter/apps/skulking"
MODE="${MODE:-release}"
TARGET="${1:-auto}"
SHOW_ADMOB="${SHOW_ADMOB:-true}"

export PATH="/Users/yee/Programs/flutter/bin:/opt/homebrew/bin:$PATH"

info() { printf "\033[1;34m[run]\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[run] ! %s\033[0m\n" "$*"; }
err()  { printf "\033[1;31m[run] x %s\033[0m\n" "$*"; }

usage() {
  sed -n '2,18p' "$0" | sed 's/^# \{0,1\}//'
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

case "$MODE" in
  debug|profile|release) ;;
  *) err "알 수 없는 MODE: $MODE (debug | profile | release)"; usage; exit 1 ;;
esac

case "$SHOW_ADMOB" in
  true|TRUE|True|yes|YES|Yes|y|Y|1) SHOW_ADMOB=true ;;
  false|FALSE|False|no|NO|No|n|N|0) SHOW_ADMOB=false ;;
  *) err "SHOW_ADMOB는 true 또는 false여야 합니다: $SHOW_ADMOB"; exit 1 ;;
esac

command -v flutter >/dev/null 2>&1 || { err "flutter 명령을 찾을 수 없습니다"; exit 1; }
[ -d "$APP_DIR" ] || { err "앱 경로를 찾을 수 없습니다: $APP_DIR"; exit 1; }

cd "$APP_DIR" || exit 1

mode_flag() {
  case "$MODE" in
    debug|profile|release) printf -- "--%s" "$MODE" ;;
    *) err "알 수 없는 MODE: $MODE (debug | profile | release)"; exit 1 ;;
  esac
}

version_args_for_platform() {
  platform="$1"
  file="$APP_DIR/release_versions/$platform.txt"
  version=""
  if [ -f "$file" ]; then
    version="$(awk 'NF {print $1; exit}' "$file")"
  fi
  [ -n "$version" ] || return 0

  build_name="${version%%+*}"
  build_number="${version#*+}"
  if [[ "$version" != *+* || ! "$build_name" =~ ^[0-9]+(\.[0-9]+){2,3}$ || ! "$build_number" =~ ^[0-9]+$ ]]; then
    err "잘못된 $platform release version: $file ($version)"
    return 1
  fi
  printf -- "--build-name=%s\n--build-number=%s\n" "$build_name" "$build_number"
}

device_platform() {
  device_id="$1"
  flutter devices --machine 2>/dev/null | python3 -c '
import json
import sys

device_id = sys.argv[1]
try:
    devices = json.load(sys.stdin)
except Exception:
    sys.exit(0)
for device in devices:
    if device.get("id") == device_id:
        target = str(device.get("targetPlatform", ""))
        if target.startswith("ios"):
            print("ios")
        elif target.startswith("android"):
            print("android")
        break
' "$device_id"
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
  local device_id="$1" label="$2" platform="${3:-}" version_lines arg
  local -a run_args
  run_args=("$(mode_flag)" "$(dart_defines)" -d "$device_id")
  if [ -n "$platform" ]; then
    version_lines="$(version_args_for_platform "$platform")" || return 1
    while IFS= read -r arg; do
      [ -n "$arg" ] && run_args+=("$arg")
    done <<< "$version_lines"
  fi
  info "$label 실행: mode=$MODE, SHOW_ADMOB=$SHOW_ADMOB, device=$device_id"
  flutter run "${run_args[@]}"
}

case "$TARGET" in
  auto)
    info "연결된 첫 기기에서 실행: mode=$MODE, SHOW_ADMOB=$SHOW_ADMOB"
    flutter run "$(mode_flag)" "$(dart_defines)"
    ;;
  ios|android)
    device="$(pick_device "$TARGET")"
    [ -n "$device" ] || { err "$TARGET 기기를 찾을 수 없습니다. flutter devices로 확인하세요."; exit 1; }
    run_device "$device" "$TARGET" "$TARGET"
    ;;
  all)
    ios_device="$(pick_device ios)"
    android_device="$(pick_device android)"
    [ -n "${ios_device}${android_device}" ] || { err "실행할 iOS/Android 기기가 없습니다"; exit 1; }

    mkdir -p "$ROOT_DIR/build/run-logs"
    pids=()
    if [ -n "$ios_device" ]; then
      info "iOS 백그라운드 실행 -> build/run-logs/ios.log"
      (run_device "$ios_device" "ios" ios) >"$ROOT_DIR/build/run-logs/ios.log" 2>&1 &
      pids+=("$!")
    else
      warn "iOS 기기 없음"
    fi

    if [ -n "$android_device" ]; then
      info "Android 백그라운드 실행 -> build/run-logs/android.log"
      (run_device "$android_device" "android" android) >"$ROOT_DIR/build/run-logs/android.log" 2>&1 &
      pids+=("$!")
    else
      warn "Android 기기 없음"
    fi

    info "로그 확인: tail -f build/run-logs/*.log"
    all_status=0
    for pid in "${pids[@]}"; do
      if ! wait "$pid"; then
        all_status=1
        warn "백그라운드 실행 프로세스 실패: pid=$pid"
      fi
    done
    exit "$all_status"
    ;;
  *)
    platform="$(device_platform "$TARGET")"
    run_device "$TARGET" "지정 기기" "$platform"
    ;;
esac
