// Script chạy 1 lần để seed dữ liệu categories vào Firestore
// Chạy: dart run lib/scripts/seed_categories.dart

import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  // Không thể chạy standalone — dùng trong app thay thế
  print('Vui lòng gọi seedCategories() từ trong app');
}

/// Gọi hàm này từ trong app (VD: từ settings hoặc debug menu)
Future<void> seedCategories(FirebaseFirestore firestore) async {
  final categories = [
    {
      'id': 'huyet_ap',
      'name': 'HUYẾT ÁP',
      'description': 'Thuốc điều trị và kiểm soát huyết áp',
      'icon': 'favorite',
      'created_at': DateTime.now().toIso8601String(),
    },
    {
      'id': 'tieu_duong',
      'name': 'TIỂU ĐƯỜNG',
      'description': 'Thuốc kiểm soát đường huyết và insulin',
      'icon': 'bloodtype',
      'created_at': DateTime.now().toIso8601String(),
    },
    {
      'id': 'bo_sung',
      'name': 'BỔ SUNG',
      'description': 'Vitamin và thực phẩm chức năng bổ sung',
      'icon': 'spa',
      'created_at': DateTime.now().toIso8601String(),
    },
    {
      'id': 'khac',
      'name': 'KHÁC',
      'description': 'Các loại thuốc chưa được phân loại',
      'icon': 'category',
      'created_at': DateTime.now().toIso8601String(),
    },
    {
      'id': 'khang_sinh',
      'name': 'KHÁNG SINH',
      'description': 'Thuốc kháng sinh điều trị nhiễm khuẩn',
      'icon': 'medication',
      'created_at': DateTime.now().toIso8601String(),
    },
    {
      'id': 'giam_dau',
      'name': 'GIẢM ĐAU',
      'description': 'Thuốc giảm đau, hạ sốt, chống viêm',
      'icon': 'healing',
      'created_at': DateTime.now().toIso8601String(),
    },
    {
      'id': 'tim_mach',
      'name': 'TIM MẠCH',
      'description': 'Thuốc điều trị các bệnh lý tim mạch',
      'icon': 'monitor_heart',
      'created_at': DateTime.now().toIso8601String(),
    },
    {
      'id': 'than_kinh',
      'name': 'THẦN KINH',
      'description': 'Thuốc an thần, chống trầm cảm, điều trị thần kinh',
      'icon': 'psychology',
      'created_at': DateTime.now().toIso8601String(),
    },
    {
      'id': 'da_day',
      'name': 'DẠ DÀY',
      'description': 'Thuốc điều trị viêm loét dạ dày, trào ngược',
      'icon': 'medical_services',
      'created_at': DateTime.now().toIso8601String(),
    },
    {
      'id': 'di_ung',
      'name': 'DỊ ỨNG',
      'description': 'Thuốc kháng histamine, chống dị ứng',
      'icon': 'local_pharmacy',
      'created_at': DateTime.now().toIso8601String(),
    },
  ];

  for (final cat in categories) {
    await firestore
        .collection('medication_categories')
        .doc(cat['id'] as String)
        .set(cat, SetOptions(merge: true));
    print('✅ Seeded: ${cat['name']}');
  }

  print('🎉 Done! Seeded ${categories.length} categories.');
}
