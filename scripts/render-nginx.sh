#!/usr/bin/env bash
# Sinh proxy/nginx-mcp.local.conf (chứa token, KHÔNG commit) từ mẫu + env/proxy.env.
set -euo pipefail
cd "$(dirname "$0")/.."
set -a; source env/proxy.env; set +a
out=proxy/nginx-mcp.local.conf
sed -e "s|__MCP_DOMAIN__|${MCP_DOMAIN}|g" \
    -e "s|__TOKEN_BAN_GIAM_DOC__|${TOKEN_BAN_GIAM_DOC}|g" \
    -e "s|__TOKEN_KINH_DOANH__|${TOKEN_KINH_DOANH}|g" \
    -e "s|__TOKEN_KE_TOAN__|${TOKEN_KE_TOAN}|g" \
    -e "s|__TOKEN_KHO_MUA_HANG__|${TOKEN_KHO_MUA_HANG}|g" \
    -e "s|__TOKEN_CSKH__|${TOKEN_CSKH}|g" \
    proxy/nginx-mcp.conf.example > "$out"
chmod 600 "$out"
echo "Đã tạo $out — chép vào /etc/nginx/conf.d/mcp.conf (chmod 600), rồi: sudo nginx -t && sudo systemctl reload nginx"
