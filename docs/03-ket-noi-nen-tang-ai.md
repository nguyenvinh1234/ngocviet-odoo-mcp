# 3. Kết nối các nền tảng AI

Địa chỉ của mỗi phòng ban: `https://mcp.<ten-mien>/<phong-ban>/mcp`. **Không thêm dấu `/` ở cuối** (proxy có xử lý, nhưng một số ứng dụng tự chuyển hướng).

Token của phòng ban nằm trong `env/proxy.env` trên server. Chỉ IT giữ file này. Mỗi người dùng nhận token qua kênh an toàn: trình quản lý mật khẩu, không gửi qua Zalo/email.

| Nền tảng | Trạng thái | Ghi chú |
|---|---|---|
| Claude Code | ✅ Giai đoạn 1 | Gửi header trực tiếp |
| Cursor / VS Code | ✅ Giai đoạn 1 | Gửi header trực tiếp |
| Claude Desktop | ✅ Giai đoạn 1 | Qua cầu nối `mcp-remote` (cần Node.js) |
| Grok qua xAI API | ✅ Giai đoạn 1 | Cần lập trình một bot nhỏ, trả phí API theo lượt dùng |
| Claude.ai (web/điện thoại) | ⏳ Giai đoạn 2 | Custom connector chỉ nhận OAuth |
| ChatGPT | ⏳ Giai đoạn 2 | Custom connector: OAuth hoặc "No Authentication" — **cấm** dùng No Authentication |
| Ứng dụng Grok, X (Twitter) | ❌ | Không phải MCP client; xem mục cuối |

## Claude Code

```bash
claude mcp add --transport http odoo-kinh-doanh \
  https://mcp.<ten-mien>/kinh-doanh/mcp \
  --header "Authorization: Bearer <TOKEN_KINH_DOANH>"
```

## Cursor (`~/.cursor/mcp.json`) / VS Code

```json
{
  "mcpServers": {
    "odoo-kinh-doanh": {
      "url": "https://mcp.<ten-mien>/kinh-doanh/mcp",
      "headers": { "Authorization": "Bearer <TOKEN_KINH_DOANH>" }
    }
  }
}
```

## Claude Desktop

Claude Desktop chỉ nhận remote connector qua OAuth, nên giai đoạn 1 dùng cầu nối `mcp-remote` chạy trên máy người dùng. Máy cần cài Node.js 20+.

Settings > Developer > Edit Config (`claude_desktop_config.json`):

```json
{
  "mcpServers": {
    "odoo-kinh-doanh": {
      "command": "npx",
      "args": [
        "-y", "mcp-remote@0.1.38",
        "https://mcp.<ten-mien>/kinh-doanh/mcp",
        "--header", "Authorization:${AUTH_HEADER}"
      ],
      "env": { "AUTH_HEADER": "Bearer <TOKEN_KINH_DOANH>" }
    }
  }
}
```

> **Lưu ý chuỗi cung ứng:** gói npm `mcp-remote` đã **đổi người phát hành** từ tháng 9/2026: các bản ≥ 0.10 phát hành từ repo `punkpeye/mcp-remote` thay vì `geelen/mcp-remote` gốc. Ở đây ghim `0.1.38`, bản cuối do tác giả gốc phát hành. Không dùng `mcp-remote@latest`. Trước khi nâng bản, IT xác minh lại nguồn gốc.
>
> Viết `Authorization:${AUTH_HEADER}` **không có dấu cách** sau dấu `:`, để tránh lỗi tách tham số trên Windows.

## Grok (xAI API)

xAI hỗ trợ "Remote MCP tools": máy chủ xAI gọi thẳng vào MCP server, và trường `authorization` được gửi trong header `Authorization`. Tài liệu: https://docs.x.ai/developers/tools/remote-mcp

Người dùng không "cắm" trực tiếp được vào ứng dụng Grok. Cần một chương trình nhỏ, ví dụ bot nội bộ hoặc script, dùng API key xAI:

```python
# pip install xai-sdk   — kiểm tra tên tham số theo tài liệu xAI hiện hành
import os
from xai_sdk import Client
from xai_sdk.chat import user
from xai_sdk.tools import mcp

client = Client(api_key=os.environ["XAI_API_KEY"])
chat = client.chat.create(
    model="grok-4",
    tools=[mcp(
        server_url="https://mcp.<ten-mien>/ban-giam-doc/mcp",
        server_label="odoo",
        authorization="Bearer " + os.environ["TOKEN_BAN_GIAM_DOC"],
    )],
)
chat.append(user("Doanh thu tháng này theo nhân viên kinh doanh?"))
print(chat.sample().content)
```

Proxy so khớp nguyên chuỗi `Bearer <token>`. Nếu `scripts/check.sh` OK mà Grok vẫn bị 401, xem `logs/caddy/mcp-access.log` (hoặc log Nginx) để biết xAI gửi header ở dạng nào, rồi chỉnh `authorization` cho khớp.

## Claude.ai và ChatGPT (giai đoạn 2)

Hai nền tảng này kết nối từ máy chủ của họ và yêu cầu **OAuth 2.1**. Proxy token đơn giản ở giai đoạn 1 không đáp ứng được. Hướng triển khai:

1. Đặt một cổng OAuth trước các instance MCP. Lựa chọn khuyến nghị: **Pomerium**, mã nguồn mở và hỗ trợ MCP chính thức (https://www.pomerium.com/docs/capabilities/mcp). Đăng nhập bằng tài khoản Google Workspace / Microsoft 365 của công ty, phân quyền theo nhóm (nhóm Kinh doanh chỉ thấy `/kinh-doanh`). Pomerium ghi log từng lần gọi tool, kèm danh tính người gọi.
2. Claude.ai: gói **Team/Enterprise**, quản trị viên thêm Custom Connector với URL phòng ban. Người dùng đăng nhập bằng tài khoản công ty khi kết nối lần đầu.
3. ChatGPT: gói **Business/Enterprise**, bật Developer mode / Apps, thêm connector với kiểu xác thực **OAuth**.

Ưu điểm so với token chung của phòng ban: mỗi người một danh tính, nghỉ việc là khóa tài khoản công ty là mất quyền ngay. Đây là lý do cuối cùng nên chuyển **mọi** nền tảng sang OAuth.

> Cấu hình Pomerium sẽ được thêm vào repo khi bắt đầu giai đoạn 2, sau khi chọn nhà cung cấp danh tính (Google hay Microsoft).

## Ứng dụng Grok và X (Twitter)

- Ứng dụng Grok (web/điện thoại) chưa cho người dùng tự thêm MCP server tùy chỉnh. Muốn dùng Grok thì đi qua xAI API như trên.
- X là mạng xã hội, không phải MCP client. Một bot trên X có thể gọi Grok API rồi gọi MCP, nhưng **không khuyến nghị**: dữ liệu ERP sẽ đi qua một kênh công khai. Nếu cần trợ lý chat cho nhân viên, nên làm bot trên kênh nội bộ (Telegram/Zalo OA/Slack nội bộ) có xác thực người dùng.

## Hướng dẫn người dùng cuối (dán vào tài liệu nội bộ)

- AI chỉ thấy dữ liệu mà phòng ban bạn được cấp. Nếu AI báo "không có quyền", đó là thiết kế, không phải lỗi.
- **Luôn kiểm tra lại số liệu** trước khi gửi khách hàng hoặc ra quyết định.
- Không dán token vào khung chat AI, email hay nhóm chat.
- Thấy AI làm điều lạ, ví dụ đề nghị sửa/xóa dữ liệu bạn không yêu cầu: dừng lại và báo IT.
