#!/usr/bin/env bash
# save_to_daily_note.sh — Append markdown to today's Capacities daily note.
#
# Usage: bash save_to_daily_note.sh "markdown text"
#
# Credentials are resolved in order:
#   1. 1Password CLI (op read) — works headless with OP_SERVICE_ACCOUNT_TOKEN
#   2. Environment variables   — CAPACITIES_API_TOKEN and CAPACITIES_SPACE_ID
#   3. Fail with instructions
#
# Configure the 1Password item references below to match your vault/item names.

set -euo pipefail

# --- 1Password references (edit these to match your vault) ---
OP_TOKEN_REF="op://Vault/Capacities API/token"
OP_SPACE_REF="op://Vault/Capacities API/space_id"

# --- Input validation ---
if [[ -z "${1:-}" ]]; then
  echo "Error: No markdown text provided." >&2
  echo "Usage: $0 \"markdown text\"" >&2
  exit 1
fi

MD_TEXT="$1"

# --- Credential resolution ---
API_TOKEN=""
SPACE_ID=""

# Tier 1: Try 1Password CLI
if command -v op &>/dev/null; then
  API_TOKEN=$(op read "$OP_TOKEN_REF" 2>/dev/null) || true
  SPACE_ID=$(op read "$OP_SPACE_REF" 2>/dev/null) || true
fi

# Tier 2: Fall back to env vars
if [[ -z "$API_TOKEN" ]]; then
  API_TOKEN="${CAPACITIES_API_TOKEN:-}"
fi
if [[ -z "$SPACE_ID" ]]; then
  SPACE_ID="${CAPACITIES_SPACE_ID:-}"
fi

# Tier 3: Fail with clear error
if [[ -z "$API_TOKEN" || -z "$SPACE_ID" ]]; then
  echo "Error: Capacities credentials not found." >&2
  echo "" >&2
  echo "Provide credentials via one of:" >&2
  echo "  1. 1Password CLI — install 'op' and store token + space_id in:" >&2
  echo "       $OP_TOKEN_REF" >&2
  echo "       $OP_SPACE_REF" >&2
  echo "     (set OP_SERVICE_ACCOUNT_TOKEN for headless use)" >&2
  echo "  2. Environment variables:" >&2
  echo "       export CAPACITIES_API_TOKEN=\"your-api-token\"" >&2
  echo "       export CAPACITIES_SPACE_ID=\"your-space-id\"" >&2
  exit 1
fi

# --- Build JSON payload ---
JSON_BODY=$(jq -n \
  --arg spaceId "$SPACE_ID" \
  --arg mdText "$MD_TEXT" \
  '{
    spaceId: $spaceId,
    mdText: $mdText,
    origin: "commandPalette",
    noTimeStamp: false
  }')

# --- API call ---
RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X POST "https://api.capacities.io/save-to-daily-note" \
  -H "Authorization: Bearer $API_TOKEN" \
  -H "Content-Type: application/json" \
  -d "$JSON_BODY")

HTTP_BODY=$(echo "$RESPONSE" | sed '$d')
HTTP_CODE=$(echo "$RESPONSE" | tail -1)

case "$HTTP_CODE" in
  200) echo "Saved to daily note." ;;
  401)
    echo "Error: Authentication failed (HTTP 401). Check your API token." >&2
    exit 1
    ;;
  429)
    echo "Error: Rate limit exceeded (HTTP 429). Max 5 requests per minute." >&2
    exit 1
    ;;
  *)
    echo "Error: API returned HTTP $HTTP_CODE" >&2
    [[ -n "$HTTP_BODY" ]] && echo "$HTTP_BODY" >&2
    exit 1
    ;;
esac
