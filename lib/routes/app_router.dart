import 'dart:async';
import 'package:firebase_auth_db_storage/provider/auth/auth_provider.dart';
import 'package:firebase_auth_db_storage/screens/auth/login_screen.dart';
import 'package:firebase_auth_db_storage/screens/home_screen.dart';
import 'package:firebase_auth_db_storage/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authStateStream = ref.watch(authStateProvider.stream);
  final authService = ref.watch(authServiceProvider);
  final needsVerification = authService.needsEmailVerification();

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStreamNotifier(authStateStream),
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
      // GoRoute(path: '/signup', builder: (context, state) => SignUpScreen()),
      // GoRoute(path: '/forgot-password', builder: (context, state) => ForgotPasswordScreen()),
      // GoRoute(path: '/verification', builder: (context, state) => EmailVerificationScreen()),
      GoRoute(path: '/home', builder: (context, state) => HomeScreen()),
    ],
    redirect: (context, state) {
      final isAuthenticated = ref.read(authStateProvider).valueOrNull != null;
      final isAuthenticating = ref.read(authStateProvider).isLoading;
      final currentLocation = state.uri.toString();

      if (isAuthenticating) {
        return currentLocation == '/splash' ? null : '/splash';
      }

      final isAuthRoute =
          currentLocation == '/login' ||
          currentLocation == '/signup' ||
          currentLocation == '/forgot-password';

      if (isAuthenticated) {
        if (needsVerification) {
          return currentLocation == '/verification' ? null : '/verification';
        } else {
          return currentLocation == '/home' ? null : '/home';
        }
      } else {
        return isAuthRoute ? null : '/login';
      }
    },
    errorBuilder:
        (context, state) =>
            Scaffold(body: Center(child: Text("Error: ${state.error}"))),
  );
});

class GoRouterRefreshStreamNotifier extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStreamNotifier(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
