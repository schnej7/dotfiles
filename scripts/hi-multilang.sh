#!/usr/bin/env bash
set -euo pipefail

TARGET="channel:1416850918602838068"
LANGS=(
  "Hola (Spanish)"
  "Bonjour (French)"
  "Hallo (German)"
  "Ciao (Italian)"
  "Olá (Portuguese)"
  "Namaste (Hindi)"
  "Konnichiwa (Japanese)"
  "Annyeong (Korean)"
  "Salaam (Arabic)"
  "Shalom (Hebrew)"
  "Jambo (Swahili)"
)
index=$((RANDOM % ${#LANGS[@]}))
greeting=${LANGS[$index]}
timestamp=$(date -Iseconds)
message="${greeting}! — scheduled hi test ${timestamp}"

/home/gene/.nvm/versions/node/v24.14.0/bin/openclaw message send --channel discord --target "$TARGET" --message "$message"
