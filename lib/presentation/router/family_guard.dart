import 'package:auto_route/auto_route.dart';
import 'package:family_health/domain/repositories/user_repository.dart';
import 'package:family_health/presentation/router/router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

@singleton
class FamilyGuard extends AutoRouteGuard {
  FamilyGuard(this._userRepository);
  final UserRepository _userRepository;

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
      final userEntity = await _userRepository.getUser(user.uid);
      if (userEntity != null && userEntity.familyId != null && userEntity.familyId!.isNotEmpty) {
        resolver.next(true);
      } else {
        // Not in a family, redirect to selection
        router.push(const FamilyGroupRoute());
        resolver.next(false);
      }
    } catch (e) {
      // In case of error (e.g. offline), we might want to let them through or show error
      // Letting them through for now to avoid blocking the app on network issues
      resolver.next(true);
    }
  }
}
