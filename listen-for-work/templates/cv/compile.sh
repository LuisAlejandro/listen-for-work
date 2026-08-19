#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

DOCKER_USER="${DOCKER_USER:-$(id -u):$(id -g)}"
export LISTEN_FOR_WORK_HOME="${LISTEN_FOR_WORK_HOME:-$HOME/listen-for-work}"
COMPOSE=(docker compose -p latex -f docker-compose.yml)

usage() {
  echo "usage: $0 <slug>       compile output/<slug>/cv.tex" >&2
  echo "       $0 --generate   compile input/cv-base.tex" >&2
  echo "       $0 --build ...  rebuild the image first" >&2
  exit 1
}

mkdir -p \
  "$LISTEN_FOR_WORK_HOME/input" \
  "$LISTEN_FOR_WORK_HOME/output" \
  "$LISTEN_FOR_WORK_HOME/job-descriptions" \
  "$LISTEN_FOR_WORK_HOME/digest"

force_build=0
if [[ "${1:-}" == "--build" ]]; then
  force_build=1
  shift
fi

if [[ "${1:-}" == "--generate" ]]; then
  cmd='cd /data/input && xelatex cv-base.tex'
elif [[ -n "${1:-}" ]]; then
  slug="$1"
  if [[ ! "$slug" =~ ^[a-zA-Z0-9-]+$ ]]; then
    echo "error: slug must be letters, digits, or hyphens: $slug" >&2
    exit 1
  fi
  cmd="cd /data/output/${slug} && xelatex cv.tex"
else
  usage
fi

if [[ "$force_build" -eq 1 ]] || ! docker image inspect listen-for-work-latex:latest >/dev/null 2>&1; then
  "${COMPOSE[@]}" build
fi

"${COMPOSE[@]}" run --rm --user "$DOCKER_USER" latex sh -c "$cmd"
