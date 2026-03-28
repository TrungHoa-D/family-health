import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

import 'router.dart';

@singleton
class AuthGuard extends AutoRouteGuard {
  AuthGuard();

  @override
  Future<void> onNavigation(
    NavigationResolver resolver,
    StackRouter router,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      resolver.next(true);
    } else {
      router.push(const LoginRoute());
      resolver.next(false);
    }
  }
}
