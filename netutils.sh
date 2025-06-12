#!/usr/bin/env bash
#
# netutils.sh — Networking Utility Toolkit for Linux
#
# Usage:
#   ./netutils.sh <command> [options]
#
# Commands:
#   download   Download a file (curl|wget)
#   upload     Upload a file (scp|rsync|nc)
#   scan       Port/service scan (nmap)
#   pingtest   Latency test (ping)
#   throughput Throughput test (iperf3)
#
# Logging: all stdout/stderr → netutils.log
# Requires: bash, curl, wget, nmap, ping, iperf3, scp, rsync, nc

set -euo pipefail
IFS=$'\n\t'

LOGFILE="netutils.log"
exec > >(tee -a "$LOGFILE") 2>&1

function die() {
  echo "ERROR: $*" >&2
  exit 1
}

function check_dep() {
  command -v "$1" >/dev/null 2>&1 \
    || die "Missing dependency: $1"
}

# Ensure dependencies
for cmd in bash curl wget nmap ping iperf3 scp rsync nc; do
  check_dep "$cmd"
done

function usage() {
  cat <<EOF
Usage: $0 <command> [options]

Commands:
  download   -u URL [-o FILE] [--resume]
  upload     -p scp|rsync|nc -s SOURCE -d DEST -h HOST [-P PORT] [-u USER]
  scan       -t TARGET [-p PORTS] [-s TYPE] [-o OUTFILE]
  pingtest   -t TARGET [-c COUNT] [-i INTERVAL]
  throughput -h HOST [-p PORT] [-d DURATION]

Run '$0 <command> --help' for command-specific options.
EOF
  exit 1
}

### download ###
function cmd_download() {
  local URL="" OUT="" RESUME=0
  # parse opts
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -u|--url)    URL="$2"; shift 2 ;;
      -o|--out)    OUT="$2"; shift 2 ;;
      --resume)    RESUME=1; shift ;;
      -h|--help)   echo "download -u URL [-o FILE] [--resume]"; exit ;;
      *) die "download: bad option $1" ;;
    esac
  done
  [[ -n "$URL" ]] || die "download: URL required"
  [[ -n "$OUT" ]] || OUT=$(basename "$URL")
  echo "[download] $URL → $OUT"
  if [[ $RESUME -eq 1 ]]; then
    curl -L -C - -o "$OUT" "$URL" \
      || wget -c -O "$OUT" "$URL"
  else
    curl -L -o "$OUT" "$URL" \
      || wget -O "$OUT" "$URL"
  fi
  echo "Downloaded to $OUT"
}

### upload ###
function cmd_upload() {
  local PROTO="" SRC="" DST="" HOST="" USER="" PORT=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -p|--proto) PROTO="$2"; shift 2 ;;
      -s|--source)SRC="$2"; shift 2 ;;
      -d|--dest)  DST="$2"; shift 2 ;;
      -h|--host)  HOST="$2"; shift 2 ;;
      -u|--user)  USER="$2"; shift 2 ;;
      -P|--port)  PORT="$2"; shift 2 ;;
      --help)     echo "upload -p scp|rsync|nc -s SRC -d DST -h HOST [-P PORT] [-u USER]"; exit ;;
      *) die "upload: bad option $1" ;;
    esac
  done
  [[ -f "$SRC" ]] || die "upload: source file missing"
  [[ -n "$DST" && -n "$HOST" && -n "$PROTO" ]] \
    || die "upload: missing required parameters"
  USER_HOST=${USER:+$USER@}$HOST
  case "$PROTO" in
    scp)
      args=(-P "${PORT:-22}")
      scp "${args[@]}" "$SRC" "$USER_HOST":"$DST"
      ;;
    rsync)
      args=(-e "ssh -p ${PORT:-22}")
      rsync -avz "${args[@]}" "$SRC" "$USER_HOST":"$DST"
      ;;
    nc)
      # On remote: nc -l -p <port> > dest
      PORT=${PORT:-9001}
      cat "$SRC" | nc "$HOST" "$PORT"
      ;;
    *) die "upload: unsupported proto '$PROTO'" ;;
  esac
  echo "Uploaded $SRC → $USER_HOST:$DST"
}

### scan ###
function cmd_scan() {
  local TARGET="" PORTS="1-1024" TYPE="-sS" OUT=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -t|--target)  TARGET="$2"; shift 2 ;;
      -p|--ports)   PORTS="$2"; shift 2 ;;
      -s|--type)    TYPE="$2"; shift 2 ;;
      -o|--output)  OUT="$2"; shift 2 ;;
      --help)       echo "scan -t TARGET [-p PORTS] [-s TYPE] [-o OUTFILE]"; exit ;;
      *) die "scan: unknown option $1" ;;
    esac
  done
  [[ -n "$TARGET" ]] || die "scan: target required"
  echo "[scan] $TARGET ports=$PORTS"
  if [[ -n "$OUT" ]]; then
    nmap $TYPE -p "$PORTS" -oN "$OUT" "$TARGET"
    echo "Scan results → $OUT"
  else
    nmap $TYPE -p "$PORTS" "$TARGET"
  fi
}

### pingtest ###
function cmd_pingtest() {
  local TARGET="" COUNT=4 INTERVAL=1
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -t|--target)   TARGET="$2"; shift 2 ;;
      -c|--count)    COUNT="$2"; shift 2 ;;
      -i|--interval) INTERVAL="$2"; shift 2 ;;
      --help)        echo "pingtest -t TARGET [-c COUNT] [-i INTERVAL]"; exit ;;
      *) die "pingtest: bad option $1" ;;
    esac
  done
  [[ -n "$TARGET" ]] || die "pingtest: target required"
  echo "[pingtest] $TARGET x$COUNT"
  ping -c "$COUNT" -i "$INTERVAL" "$TARGET"
}

### throughput ###
function cmd_throughput() {
  local HOST="" PORT=5201 DURATION=10
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--host)    HOST="$2"; shift 2 ;;
      -p|--port)    PORT="$2"; shift 2 ;;
      -d|--duration)DURATION="$2"; shift 2 ;;
      --help)       echo "throughput -h HOST [-p PORT] [-d DURATION]"; exit ;;
      *) die "throughput: unknown option $1" ;;
    esac
  done
  [[ -n "$HOST" ]] || die "throughput: host required"
  echo "[throughput] $HOST:$PORT for $DURATION sec"
  # server: iperf3 -s -p $PORT
  iperf3 -c "$HOST" -p "$PORT" -t "$DURATION"
}

# dispatch
[[ $# -ge 1 ]] || usage
cmd="$1"; shift
case "$cmd" in
  download)   cmd_download "$@" ;;
  upload)     cmd_upload   "$@" ;;
  scan)       cmd_scan     "$@" ;;
  pingtest)   cmd_pingtest "$@" ;;
  throughput) cmd_throughput "$@" ;;
  -h|--help)  usage ;;
  *)          die "Unknown command '$cmd'" ;;
esac

exit 0
