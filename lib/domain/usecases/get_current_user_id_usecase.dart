import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetCurrentUserIdUseCase {
  GetCurrentUserIdUseCase() : _firebaseAuth = FirebaseAuth.instance;
  final FirebaseAuth _firebaseAuth;

  String? call() {
    return _firebaseAuth.currentUser?.uid;
  }
}
