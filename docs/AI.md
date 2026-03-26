# AI Agent Guidelines cho Dự án Family Health

File tài liệu này chứa tất cả các nguyên tắc, chuẩn coding, kiến trúc và hệ thống thiết kế (Design System) mà AI cần tuân thủ khi viết code hoặc debug cho dự án Flutter này. **Tuyệt đối tham khảo và làm theo phân tích ở đây trước khi đề xuất thay đổi.**

---

## 🏗️ 1. Kiến trúc \& State Management

- **Clean Architecture**: Tuân thủ nghiêm ngặt mô hình `Presentation` -> `Domain` -> `Data`. Không gọi trực tiếp Data layer (hoặc service như Firebase) từ UI. Mọi request đều phải chạy qua UseCase / Repository.
- **State Management**: Sử dụng `flutter_bloc` (Cubit hoặc Bloc). UI luôn được render dựa trên state từ BlocBuilder/BlocListener. Các Page phải extend `BaseCubitPage`.
- **Dependency Injection (DI)**: Sử dụng `get_it` và `injectable`. Bất kỳ Repository, UseCase, DataSource hay third-party module (Firebase) nào mới đều phải được khai báo DI đàng hoàng (như `@Injectable`, `@Singleton`, `@LazySingleton` hoặc `module`). Chạy `flutter pub run build_runner build --delete-conflicting-outputs` khi map DI mới.
- **Routing**: Dự án sử dụng `auto_route`. Mọi trang (Page) mới đều phải được đánh dấu bằng annotation `@RoutePage()` và khai báo trong `app_router.dart`.
- **Localization**: Dùng `easy_localization`. Các text hiển thị trên UI phải bọc trong hàm `.tr()`, ví dụ: `'home.title'.tr()`.

---

## 🎨 2. Hệ thống Thiết kế (Design System & Style Guide)

Dự án đã định nghĩa sẵn các class để phục vụ cho UI (nằm trong `lib/presentation/resources/`). **Cấm sử dụng hardcode màu sắc, font chữ, hoặc kích thước.** Luôn luôn dùng các token đã định nghĩa.

### A. Màu sắc (`AppColors`)
- **KHÔNG sử dụng** các màu cũ như `denim`, `pattensBlue`, `suvaGrey` (đã bị xóa bỏ).
- Dùng `AppColors.primary` (`#0066FF`) làm màu chủ đạo (nút, tab đang chọn, link).
- Dùng `AppColors.surface` (`#F5F5F5`) cho nền input, card loading.
- Dùng `AppColors.background` (`#FFFFFF`) cho nền ứng dụng ở Standard mode.
- Dùng các màu ngữ nghĩa: `AppColors.success`, `AppColors.warning`, `AppColors.error`.
- Dành cho **Simplified Mode**: Dùng `AppColors.simplifiedBg` (`#1A1A2E`), `AppColors.simplifiedSurface` (`#2A2A40`), và `AppColors.simplifiedText`.

### B. Typography (`AppStyles`)
- Font chữ mặc định của hệ thống là **Inter** (fallback GoogleSans). File cài đặt là `fonts.gen.dart` (`FontFamily.inter`).
- **Nghiêm cấm** dùng các style cũ (đã `@Deprecated`) như `AppStyles.h1`, `AppStyles.h2`, `AppStyles.title`, `AppStyles.primary`, `AppStyles.small`.
- Bắt buộc dùng hệ text scale mới theo chuẩn Material 3:
  - `displayLarge`, `headlineLarge`, `headlineMedium` (Tiêu đề lớn/trang).
  - `titleXLarge`, `titleLarge`, `titleMedium`, `titleSmall` (Tiêu đề nhóm/card).
  - `bodyLarge` (16sp), `bodyMedium` (15sp), `bodySmall` (14sp) (Nội dung chính).
  - `labelLarge`, `labelMedium`, `labelSmall` (Nút bấm, caption, timestamp).
  - Các biến thể Simplified: `simplifiedBody`, `simplifiedTitle`, `simplifiedButton`.

### C. Khoảng cách & Kích thước (`AppSpacing`)
Tất cả các con số liên quan đến margin, padding, height, radius phải lấy từ `AppSpacing`:
- **Spacing**: `xs` (4), `sm` (8), `md` (16), `lg` (24), `xl` (32), `xxl` (48).
- **Border Radius**:
  - `radiusInput` (12px).
  - `radiusCard` (16px).
  - `radiusButton` (24px - dạng Capsule).
- **Component Height**: `buttonHeight` (48dp), `buttonHeightSimplified` (72dp), `inputHeight` (52dp), `bottomNavHeight` (56dp).

---

## 🧩 3. Các Widget UI Chuẩn mực có sẵn

Nếu cần tạo UI mới, luôn ưu tiên sử dụng các Custom Widget sau thay vì dùng Widget mặc định của Flutter:

1. **`AppButton`**: Nút bấm chính.
   - Mặc định bo tròn dạng viên thuốc (radius 24), chiều cao 48dp, có bóng đổ mờ.
   - Gọi `AppButton.simplified(...)` nếu cần tạo nút khổng lồ 72dp cho chế độ người lớn tuổi.
   - Gọi `AppButton.outline(...)` cho nút phụ.

2. **`AppCard`**: Thẻ nội dung cơ bản.
   - Default: nền trắng, bo góc 16px, không có viền rõ (chỉ có shadow nhẹ `0 2px 8px`).
   - Có cờ `enableShadow` và `hasBorder` hỗ trợ.

3. **`AppFormField`**: Ô nhập liệu chuẩn hóa.
   - Default: Cao 52dp, nền `#F5F5F5` (`surface`), không có viền khi chưa focus.
   - Khi focus sẽ hiện viền màu `primary`.

4. **`AppAvatar`**: Widget cho ảnh đại diện.
   - Luôn luôn là hình tròn dạng `CircleAvatar` có viền `primaryLight`. Có ảnh network tự động set fallback icon.
   - Có các constructor theo size: `.small()`, `.medium()`, `.large()`, `.xlarge()`, `.xxlarge()`.

---

## 🔥 4. Firebase & Cơ Sở Dữ Liệu
- Firebase đã được cấu hình tích hợp. Khởi tạo ở `main.dart` thông qua `firebase_options.dart`.
- Trong môi trường test local (chạy máy ảo hệ điều hành Windows), **Google Sign In (OAuth) không được hỗ trợ**. Thay vào đó, nếu cần dev flow đăng nhập/đăng ký hãy dùng Email/Password cho bản debug.
- Database là **Firestore**. Tên Collections chuẩn: `users`, `health_profiles`, `family_groups`, `medications`, `patient_schedules`, `medical_events`, `medication_logs`, `chats`. (Chi tiết các field hãy tham khảo `docs/basic_design.md`).
- Thông tin nhạy cảm Firebase Keys, file config phải luôn được block trong `.gitignore` để tránh rò rỉ.

---

## 💡 5. Cách giao tiếp của AI

1. Đọc kĩ `docs/AI.md` này và tài liệu thiết kế `docs/basic_design.md` trước khi giải quyết task mới.
2. Tránh hỏi lại những quy tắc đã chốt trong này.
3. Không làm giả/sử dụng "placeholders" bừa bãi khi xử lý UI (ví dụ màu đỏ/xanh lá chói mắt để test layout). Phải dùng token từ `AppColors`. Giao diện phải mang tính Aesthetics đẹp mắt.
4. Khi sửa nhiều file hoặc thêm lib mới, nên cập nhật docs/AI.md nếu cần thiết lập pattern mới.
5. **Localization Bắt Buộc**: Bất kỳ đoạn text nào hiển thị trên UI đều **TUYỆT ĐỐI KHÔNG ĐƯỢC HARDCODE**. Phải tạo key đồng thời trong `assets/translations/en.json` và `vi.json`, sau đó sử dụng extension `.tr()` để hiển thị.
