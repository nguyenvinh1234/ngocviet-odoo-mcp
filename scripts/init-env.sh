#!/usr/bin/env bash
# Tạo env/*.env từ mẫu (không ghi đè file đã có) và sinh token ngẫu nhiên cho proxy.
set -euo pipefail
cd "$(dirname "$0")/.."

for example in env/*.env.example; do
  target="${example%.example}"
  if [[ ! -f "$target" ]]; then
    cp "$example" "$target"
    echo "Tạo $target"
  fi
done

for var in TOKEN_BAN_GIAM_DOC TOKEN_KINH_DOANH TOKEN_KE_TOAN TOKEN_KHO_MUA_HANG TOKEN_CSKH; do
  if grep -qE "^${var}=$" env/proxy.env; then
    sed -i "s|^${var}=$|${var}=$(openssl rand -hex 32)|" env/proxy.env
    echo "Sinh $var"
  fi
done

chmod 600 env/*.env
mkdir -p logs/caddy
# Container chạy bằng user mcp (uid 1000) cần ghi được log.
if [[ "$(stat -c %u logs)" != "1000" ]]; then
  sudo chown -R 1000:1000 logs
fi

echo
echo "Tiếp theo: điền ODOO_URL/ODOO_DB/ODOO_MCP_ALLOWED_HOSTS trong env/common.env,"
echo "ODOO_API_KEY trong từng env/<phong-ban>.env, MCP_DOMAIN/ACME_EMAIL trong env/proxy.env."
