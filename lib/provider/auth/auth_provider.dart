import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_db_storage/provider/auth/auth_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

final emailVerifiedProvider = Provider<bool>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.isEmailVerified;
});
