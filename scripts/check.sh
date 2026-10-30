#!/usr/bin/env bash
# Kiểm tra từng phòng ban qua proxy công khai:
#   - không token  → phải bị chặn (401)
#   - đúng token   → MCP initialize thành công (200)
set -uo pipefail
cd "$(dirname "$0")/.."
set -a; source env/proxy.env; set +a

declare -A TOKENS=(
  [ban-giam-doc]="$TOKEN_BAN_GIAM_DOC"
  [kinh-doanh]="$TOKEN_KINH_DOANH"
  [ke-toan]="$TOKEN_KE_TOAN"
  [kho-mua-hang]="$TOKEN_KHO_MUA_HANG"
  [cskh]="$TOKEN_CSKH"
)
INIT='{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"ngocviet-check","version":"1"}}}'
fail=0

for dept in "${!TOKENS[@]}"; do
  url="https://${MCP_DOMAIN}/${dept}/mcp"
  token="${TOKENS[$dept]}"
  if [[ ${#token} -lt 32 ]]; then
    echo "LỖI  $dept: token rỗng hoặc quá ngắn — chạy scripts/init-env.sh"; fail=1; continue
  fi
  no_auth=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$url" \
    -H 'Content-Type: application/json' -H 'Accept: application/json, text/event-stream' -d "$INIT")
  with_auth=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$url" \
    -H "Authorization: Bearer $token" \
    -H 'Content-Type: application/json' -H 'Accept: application/json, text/event-stream' -d "$INIT")
  if [[ "$no_auth" == "401" && "$with_auth" == "200" ]]; then
    echo "OK   $dept (không token: $no_auth, có token: $with_auth)"
  else
    echo "LỖI  $dept (không token: $no_auth — cần 401, có token: $with_auth — cần 200)"; fail=1
  fi
done
exit $fail
