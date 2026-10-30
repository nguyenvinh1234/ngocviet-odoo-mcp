# 5. Nâng cấp Odoo 16 → Odoo 20 Community

Kế hoạch: chuẩn hóa dữ liệu trên Odoo 16 trước, rồi mới nâng cấp. Phần dưới chỉ nói những gì **liên quan đến MCP**. Bản thân việc nâng cấp database cần một kế hoạch riêng.

## Lưu ý về nâng cấp Community

- Dịch vụ nâng cấp chính thức của Odoo (upgrade.odoo.com) dành cho bản **Enterprise**. Bản Community thường nâng cấp bằng **OpenUpgrade** của OCA: https://github.com/OCA/OpenUpgrade
- Phải nâng **từng bậc**: 16 → 17 → 18 → 19 → 20. Mỗi bậc chạy và kiểm tra riêng. Trước khi bắt đầu, xác nhận OpenUpgrade đã có nhánh cho **từng** bậc; bậc mới nhất thường ra muộn hơn bản Odoo.
- Mọi module bên ngoài, kể cả `mcp_server`, cần bản tương ứng với từng phiên bản Odoo.
- Luôn làm trên bản sao trước, giữ nguyên Odoo 16 chạy song song cho tới khi nghiệm thu xong.

## Những thay đổi phía MCP khi lên Odoo 20

| Hạng mục | Odoo 16 | Odoo 20 | Việc cần làm |
|---|---|---|---|
| Module MCP | `mcp_server` bản 16.0 | `mcp_server` bản 20.0 | Cài lại, bật lại model theo [ma trận quyền](ma-tran-quyen.md) |
| API key | Key thường | Key phải có **scope `rpc`** | Tạo lại key cho 5 user AI, chọn scope `rpc` |
| Tên database | Tự dò được | `/xmlrpc/db` đã bị bỏ | `ODOO_DB` phải ghi rõ (repo đã đặt sẵn) |
| Nhóm MCP User | Có | Có | Kiểm tra 5 user AI vẫn thuộc nhóm |
| Tên model/trường | — | Một số đổi tên giữa các bản | Rà lại ma trận quyền; chạy kiểm thử định kỳ |

## Trình tự chuyển MCP sang Odoo 20

1. Odoo 20 staging đã nâng cấp xong và nghiệm thu nghiệp vụ.
2. Cài `mcp_server` bản 20.0, bật model, tạo lại API key (scope `rpc`) cho 5 user AI.
3. Trên server: đổi `ODOO_URL`/`ODOO_DB` trong `env/common.env` và `ODOO_API_KEY` trong từng `env/<phong-ban>.env` trỏ tới staging 20, rồi `docker compose up -d`.
4. Chạy [kiểm thử định kỳ](04-van-hanh-bao-mat.md#kiểm-thử-định-kỳ).
5. Ngày chuyển chính thức: trỏ sang database Odoo 20 thật và chạy lại bước 4.
6. Ghi vào [nhật ký thay đổi quyền](nhat-ky-thay-doi-quyen.md).

mcp-server-odoo `0.9.0` đã hỗ trợ Odoo 20 (scope `rpc`, kiểm tra kích thước file đính kèm kiểu mới). Nếu lúc nâng cấp đã có bản mới hơn, nâng cùng lúc theo quy trình ở [02](02-trien-khai.md#26-cập-nhật-phiên-bản-mcp-server-odoo).
