# Kế hoạch Hoàn thiện Ứng dụng Family Health (Chi tiết)

## 1. Mục tiêu và Phạm vi
Chuyển đổi ứng dụng từ dạng UI Prototype sang ứng dụng hoạt động hoàn chỉnh (MVP) với dữ liệu thực tế từ Firebase Firestore, tích hợp AI (Gemini) và hệ thống thông báo đa nền tảng.

## 2. Các Công nghệ chính
- **AI**: Google Gemini API (Phân tích thuốc & Trợ lý).
- **Database**: Firebase Firestore.
- **Notification**: Firebase Cloud Messaging (FCM) & `flutter_local_notifications`.
- **State Management**: Bloc/Cubit (theo chuẩn hiện tại).

## 3. Lộ trình Triển khai Chi tiết

### Phần 1: Xây dựng Nền tảng Dữ liệu (Dự kiến: 2-3 ngày)
- **Thiết kế Firestore Schema**:
  - `users`: Thông tin chi tiết người dùng, avatar.
  - `family_groups`: Nhóm gia đình, mã mời, danh sách `admin_ids` và `member_ids`.
  - `medications`: Thông tin thuốc (tên, liều lượng, loại).
  - `patient_schedules`: Lịch uống thuốc cụ thể của từng thành viên.
  - `medication_logs`: Nhật ký thực tế (đã uống / bỏ lỡ).
- **Triển khai Repositories**:
  - `FamilyRepository`: Quản lý việc tạo/gia nhập nhóm.
  - `MedicationRepository`: CRUD thuốc và lịch trình.
  - `LogRepository`: Ghi nhật ký uống thuốc.

### Phần 2: Luồng Thiết lập Gốc (Dự kiến: 2 ngày)
- **Login & Onboarding**:
  - Kết nối Login với `syncUser` trong Firestore.
  - Hoàn thiện UI trang "Chọn UI Mode" để lưu cấu hình này vào Firestore.
- **Quản lý Gia đình**:
  - Tạo logic sinh mã mời 6 ký tự ngẫu nhiên.
  - API Join Family: Kiểm tra mã mời và thêm member vào nhóm.
  - Admin Dashboard: Xem danh sách thành viên và gửi lời mời.

### Phần 3: Tủ thuốc & Phân tích AI (Dự kiến: 3-4 ngày)
- **Đồng bộ Tủ thuốc**:
  - Thay thế dữ liệu mock trong `MedsCubit` bằng `Stream` từ Firestore để cập nhật realtime.
- **AI Camera (OCR)**:
  - Sử dụng Gemini Pro Vision để phân tích ảnh đơn thuốc.
  - Tự động điền (Auto-fill) các trường thông tin: Tên thuốc, Liều lượng, Tần suất.
- **Trợ lý Y khoa**:
  - Màn hình chat AI chuyên biệt khi xem chi tiết thuốc.

### Phần 4: Thông báo & Lịch trình (Dự kiến: 3 ngày)
- **Notification Manager**:
  - **Local Notifications**: Lên lịch thông báo uống thuốc cục bộ dựa trên dữ liệu tải về.
  - **Push Notifications (FCM)**: Thông báo cho con cái khi cha mẹ bỏ lỡ liều thuốc (Late Alert).
- **Dashboard Summary**:
  - Tổng hợp dữ liệu thành phần trăm hoàn thành theo ngày/thành viên.

### Phần 5: Chat & Hoàn thiện UI (Dự kiến: 2 ngày)
- **Family Chat**:
  - Firestore Realtime listener cho tin nhắn.
  - Support ảnh và Quick Reply (cho Simplified Mode).
- **Simplified Mode (Người cao tuổi)**:
  - Tối ưu hóa UI: Nút xác nhận uống thuốc khổng lồ, widget Dashboard đơn giản nhất.

## 4. Danh sách Công việc (Checklist)
- [ ] Thiết lập DI cho các Repository mới.
- [ ] Implement `FamilyDataSource`.
- [ ] Cập nhật `MedsCubit` sử dụng UseCases.
- [ ] Cấu hình Gemini API và Prompting.
- [ ] Cài đặt Native code cho Local Notifications (Windows/Android/iOS).
- [ ] Testing đa tài khoản trên Emulator.

---
**Ghi chú**: Mọi thay đổi sẽ tuân thủ nghiêm ngặt file `docs/AI.md` về kiến trúc và Design System.
