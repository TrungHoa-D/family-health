import 'package:auto_route/auto_route.dart';
import 'package:family_health/domain/repositories/user_repository.dart';
import 'package:family_health/domain/repositories/family_repository_interface.dart';
import 'package:family_health/presentation/router/router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

@singleton
class FamilyGuard extends AutoRouteGuard {
  FamilyGuard(this._userRepository, this._familyRepository);
  final UserRepository _userRepository;
  final FamilyRepository _familyRepository;

  @override
  Future<void> onNavigation(
    NavigationResolver resolver,
    StackRouter router,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // AuthGuard should handle this, but for safety:
      resolver.next(true);
      return;
    }

    try {
      // Luôn lấy dữ liệu mới nhất từ Firestore
      final userEntity = await _userRepository.getUser(user.uid);
      
      if (userEntity != null && 
          userEntity.familyId != null && 
          userEntity.familyId!.isNotEmpty) {
        
        // Kiểm tra thêm xem FamilyGroup có thực sự tồn tại không (Phòng trường hợp bị giải tán)
        final familyGroup = await _familyRepository.getFamilyGroup(userEntity.familyId!);
        
        if (familyGroup != null) {
          resolver.next(true);
          return;
        }
      }
      
      // Nếu không có family_id hoặc group không tồn tại, điều hướng về trang setup/join
      router.push(const FamilyGroupRoute());
      resolver.next(false);
    } catch (e) {
      // Trong trường hợp lỗi network, tạm thời cho qua để không block app hoàn toàn
      // nhưng LoginCubit đã xử lý fetch an toàn trước đó rồi
      resolver.next(true);
    }
  }
}
