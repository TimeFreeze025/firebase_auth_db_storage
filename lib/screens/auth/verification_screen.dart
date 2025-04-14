import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_db_storage/provider/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class EmailVerificationScreen extends HookConsumerWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEmailSent = useState(false);
    final isLoading = useState(false);
    final lastResendAttempt = useState<DateTime?>(null);
    final verficationTimer = useRef<Timer?>(null);
    const resendCooldown = Duration(seconds: 30);

    Future<void> sendVerificationEmail(
      ValueNotifier<bool> isEmailSent,
      ValueNotifier<DateTime?> lastResendAttempt,
      WidgetRef ref,
    ) async {
      if (lastResendAttempt.value != null &&
          DateTime.now().difference(lastResendAttempt.value!) <
              resendCooldown) {
        final remaining =
            resendCooldown -
            DateTime.now().difference(lastResendAttempt.value!);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Please wait ${remaining.inSeconds} seconds before resending the email.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      try {
        await ref.read(authServiceProvider).sendEmailVerification();
        isEmailSent.value = true;
        lastResendAttempt.value = DateTime.now();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Verification email sent!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        Future.delayed(Duration(seconds: 3), () {
          if (context.mounted) {
            isEmailSent.value = false;
          }
        });
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    Future<void> checkVerificationStatus(
      ValueNotifier<bool> isLoading,
      BuildContext context,
      WidgetRef ref,
    ) async {
      isLoading.value = true;
      try {
        await FirebaseAuth.instance.currentUser?.reload();
        final user = FirebaseAuth.instance.currentUser;
        if (user != null && user.emailVerified && context.mounted) {
          context.go('/home');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error checking verification status: ${e.toString()}',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        isLoading.value = false;
      }
    }

    void startVerificationTimer(
      ValueNotifier<bool> isEmailSent,
      BuildContext context,
      verficationTimerRef,
      WidgetRef ref,
    ) {
      verficationTimer.value = Timer.periodic(const Duration(seconds: 1), (_) {
        checkVerificationStatus(isLoading, context, ref);
      });
    }

    useEffect(() {
      sendVerificationEmail(isEmailSent, lastResendAttempt, ref);
      startVerificationTimer(isEmailSent, context, verficationTimer, ref);
      return () {
        verficationTimer.value?.cancel();
      };
    }, [context, ref]);

    return Scaffold(
      appBar: AppBar(
        title: Text('Verify Email'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.email_outlined, size: 80, color: Colors.orange),
            SizedBox(height: 24),
            Text(
              'Check/Verify your Email',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'A Verification email has been sent to ${ref.read(authServiceProvider).currentUser?.email}.'
              'Please check your inbox and click the verification link.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            if (isEmailSent.value)
              Text(
                'Verification email sent!, Check your Inbox',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              ElevatedButton(
                onPressed:
                    () => sendVerificationEmail(
                      isEmailSent,
                      lastResendAttempt,
                      ref,
                    ),
                child: Text('Resend Verification Email  '),
              ),
            SizedBox(height: 32),
            TextButton(
              onPressed: () async {
                await ref.read(authServiceProvider).signOut();
              },
              child: Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }
}
