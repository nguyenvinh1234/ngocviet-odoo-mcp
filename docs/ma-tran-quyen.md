# Ma trận quyền theo phòng ban (đề xuất — Ban giám đốc duyệt)

Ký hiệu: **R** đọc · **C** tạo · **W** sửa · **D** xóa · — không truy cập.
Giai đoạn 1–2: **chỉ R**. Cột "Giai đoạn 3" là quyền ghi đề xuất mở thêm, cần duyệt riêng.

Quyền thực tế = (model được bật trong module MCP) ∩ (nhóm quyền Odoo của user AI) ∩ (record rules).

| Model (Odoo 16) | Mô tả | Ban GĐ | Kinh doanh | Kế toán | Kho–Mua | CSKH | Giai đoạn 3 |
|---|---|---|---|---|---|---|---|
| `res.partner` | Khách hàng / NCC | R | R | R | R | R | KD, CSKH: C W |
| `crm.lead` | Cơ hội / lead | R | R | — | — | R | KD, CSKH: C W |
| `sale.order` | Báo giá / đơn bán | R | R | R | R | R | KD: C (chỉ báo giá nháp) |
| `sale.order.line` | Dòng đơn bán | R | R | R | R | R | KD: C W (theo báo giá nháp) |
| `product.template` / `product.product` | Sản phẩm | R | R | R | R | R | — |
| `stock.quant` | Tồn kho | R | R | — | R | R | — |
| `stock.picking` | Phiếu nhập/xuất | R | — | — | R | R | — |
| `purchase.order` | Đơn mua | R | — | R | R | — | Kho–Mua: C (nháp) |
| `account.move` | Hóa đơn / bút toán | R | — | R | — | — | **Không mở ghi** |
| `account.move.line` | Dòng bút toán | R | — | R | — | — | **Không mở ghi** |
| `account.payment` | Thanh toán | R | — | R | — | — | **Không mở ghi** |
| `mail.message` | Trao đổi trên bản ghi | R | R | R | R | R | KD, CSKH: ghi chú nội bộ (`post_message`) |
| `mail.activity` + `ir.model` | Việc cần làm | R | R | — | R | R | KD, CSKH: C |
| `hr.employee`, `hr.*` | Nhân sự | — | — | — | — | — | **Không mở** |
| `res.users`, `ir.*` khác | Hệ thống | — | — | — | — | — | **Không bao giờ** |

## Ghi chú

- Cột "—" được thực thi bằng **nhóm quyền Odoo** của user AI: không cấp nhóm Kế toán cho `ai.kinhdoanh`. Module MCP chỉ có một danh sách model chung cho mọi user.
- Quyền **D (xóa)**: không mở cho bất kỳ phòng ban nào. Muốn hủy thì dùng trạng thái "Hủy" của nghiệp vụ.
- Thêm model mới: ghi vào [nhật ký thay đổi quyền](nhat-ky-thay-doi-quyen.md), có người duyệt.
- Tên model có thể đổi khi lên Odoo 20; rà lại bảng này khi nâng cấp.
