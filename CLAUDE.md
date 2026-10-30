# Ngữ cảnh cho Claude — đọc trước khi làm bất cứ việc gì

Dự án: cho AI (Claude, ChatGPT, Grok) làm việc với Odoo của **Ngọc Việt CNC** qua MCP.
Trạng thái chi tiết, lịch sử quyết định, việc đang dở: **[docs/NGU-CANH.md](docs/NGU-CANH.md)** — đọc hết file đó.

## Quy tắc làm việc với anh Vinh (chủ dự án)

- Trả lời **tiếng Việt**, ngắn, đi thẳng vào việc. Không đưa nhiều phương án khi một cách đã rõ.
- **Kiểm tra trước khi khẳng định.** Trước khi nói "không làm được", xem `docs/NGU-CANH.md` mục "Cách truy cập" và
  lịch sử phiên — anh đã nhiều lần làm việc với server qua Claude Code trên máy tính của anh.
- Không bắt anh nhắc lại bối cảnh đã có trong file này hoặc `docs/NGU-CANH.md`.
- Hỏi trước mọi thao tác xóa, hoặc thay đổi trên Odoo/server đang chạy thật.

## Sự thật cần nhớ

- Odoo **16 Community**, `https://odoo.ngocvietai.com`, database tên **`odoo`**. Có module Website.
  Kế hoạch: chuẩn hóa dữ liệu rồi nâng lên Odoo 20 Community (cùng server).
- Module MCP phía Odoo (`mcp_server`) **chưa cài** — `/mcp/health` trả 404 (kiểm tra 30/10/2026).
- MCP server: `mcp-server-odoo` **0.9.0**, đã rà soát mã nguồn — an toàn. Ghim digest trong `docker-compose.yml`.
- **Phiên Claude chạy trên đám mây (claude.ai/code, app desktop "cloud") KHÔNG vào được server/Odoo**:
  mạng bị chặn (`odoo.ngocvietai.com`, Tailscale đều bị proxy từ chối). Việc trên server phải làm bằng
  Claude Code chạy trên **máy tính Windows của anh** (`desktop-n3dr22n`, VS Code hoặc terminal) — như các lần trước.
- Không bao giờ commit/đưa lên Drive: `env/*.env`, API key, token, mật khẩu. Chỉ file `*.example`.
