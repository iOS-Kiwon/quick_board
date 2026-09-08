#!/usr/bin/env bash
#
# Quick Board — Flutter 앱 실행 스크립트
#
set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APPS_DIR="$ROOT_DIR/quick-board-flutter/apps"
MODE="${MODE:-release}"
SHOW_ADMOB="${SHOW_ADMOB:-true}"

export PATH="/Users/yee/Programs/flutter/bin:/opt/homebrew/bin:$PATH"

info() { printf "\033[1;34m[run]\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[run] ! %s\033[0m\n" "$*"; }
err()  { printf "\033[1;31m[run] x %s\033[0m\n" "$*"; }

usage() {
  cat <<'EOF'
Quick Board — Flutter 앱 실행 스크립트

사용법:
  ./run.sh --help              도움말
  ./run.sh                     앱을 고른 뒤 연결된 첫 기기에서 실행
  ./run.sh <대상>              앱을 물어본 뒤 실행
  ./run.sh <앱> <대상>         앱까지 인자로 지정 (프롬프트 생략)

앱:
  skulking | yacht             생략하면 실행할 때 물어봅니다

대상:
  auto (기본) | android | ios | all | <deviceId>

예:
  ./run.sh                     앱을 고른 뒤 첫 기기에서 실행
  ./run.sh ios                 앱을 고른 뒤 첫 iOS 기기/시뮬레이터
  ./run.sh yacht ios           요트다이스를 첫 iOS 기기/시뮬레이터에서
  ./run.sh yacht 00008101-...  기기 ID 지정
  MODE=debug ./run.sh yacht ios

환경 변수:
  APP=skulking|yacht           앱 선택. 지정하면 묻지 않습니다
  MODE=release|debug|profile   기본 release. iOS 시뮬레이터는 debug만 됩니다
  SHOW_ADMOB=true|false        기본 true. 광고 없이 실행할 때 false
EOF
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

# ---------------------------------------------------------------------------
# 어떤 앱을 실행할지 가장 먼저 정한다.
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
  [ "${#apps[@]}" -gt 0 ] || { err "실행할 앱을 찾을 수 없습니다: $APPS_DIR"; exit 1; }

  if [ "${#apps[@]}" -eq 1 ]; then
    APP="${apps[0]}"
    return
  fi

  info "어떤 앱을 실행할까요?"
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
  err "앱을 지정하세요. 예: APP=yacht ./run.sh ios"
  exit 1
fi

APP_DIR="$APPS_DIR/$APP"
TARGET="${1:-auto}"

[ -d "$APP_DIR" ] || { err "앱 경로를 찾을 수 없습니다: $APP_DIR"; exit 1; }

info "대상 앱: $(app_label "$APP") ($APP)"
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

is_emulator() {
  flutter devices --machine 2>/dev/null | python3 -c '
import json
import sys

device_id = sys.argv[1]
try:
    devices = json.load(sys.stdin)
except Exception:
    sys.exit(1)
for device in devices:
    if device.get("id") == device_id:
        sys.exit(0 if device.get("emulator") else 1)
sys.exit(1)
' "$1"
}

# 개발 실행에는 출시 버전을 붙이지 않는다.
# flutter run 은 --build-name / --build-number 를 받지 않는다 (flutter build 전용).
run_device() {
  local device_id="$1" label="$2"
  local -a run_args

  # 시뮬레이터/에뮬레이터는 AOT 컴파일이 안 되어 release·profile 실행이 불가능하다.
  if [ "$MODE" != "debug" ] && is_emulator "$device_id"; then
    err "$label 대상이 시뮬레이터/에뮬레이터라 $MODE 모드로 실행할 수 없습니다."
    err "MODE=debug ./run.sh $APP $label 로 실행하거나 실기기를 연결하세요."
    return 1
  fi

  run_args=("$(mode_flag)" "$(dart_defines)" -d "$device_id")
  info "$label 실행: mode=$MODE, SHOW_ADMOB=$SHOW_ADMOB, device=$device_id"
  flutter run "${run_args[@]}"
}

case "$TARGET" in
  auto)
    info "연결된 첫 기기에서 실행: mode=$MODE, SHOW_ADMOB=$SHOW_ADMOB"
    flutter run "$(mode_flag)" "$(dart_defines)"
    ;;
  ios|android)
    [ -d "$APP_DIR/$TARGET" ] || {
      err "$(app_label "$APP")에는 $TARGET 폴더가 없습니다."
      exit 1
    }
    device="$(pick_device "$TARGET")"
    [ -n "$device" ] || { err "$TARGET 기기를 찾을 수 없습니다. flutter devices로 확인하세요."; exit 1; }
    run_device "$device" "$TARGET"
    ;;
  all)
    ios_device=""
    android_device=""
    [ -d "$APP_DIR/ios" ] && ios_device="$(pick_device ios)"
    [ -d "$APP_DIR/android" ] && android_device="$(pick_device android)"
    [ -n "${ios_device}${android_device}" ] || { err "실행할 iOS/Android 기기가 없습니다"; exit 1; }

    log_dir="$ROOT_DIR/build/run-logs/$APP"
    mkdir -p "$log_dir"
    pids=()
    if [ -n "$ios_device" ]; then
      info "iOS 백그라운드 실행 -> build/run-logs/$APP/ios.log"
      (run_device "$ios_device" "ios") >"$log_dir/ios.log" 2>&1 &
      pids+=("$!")
    else
      warn "iOS 기기 없음"
    fi

    if [ -n "$android_device" ]; then
      info "Android 백그라운드 실행 -> build/run-logs/$APP/android.log"
      (run_device "$android_device" "android") >"$log_dir/android.log" 2>&1 &
      pids+=("$!")
    else
      warn "Android 기기 없음"
    fi

    info "로그 확인: tail -f build/run-logs/$APP/*.log"
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
    run_device "$TARGET" "지정 기기"
    ;;
esac
