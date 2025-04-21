import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:toastification/toastification.dart';

final globalNavigatorKey = GlobalKey<NavigatorState>();

final toastProvider = Provider<Toast>((ref) {
  return Toast();
});

class Toast {
  void toastInfo({required String message, int durationInSeconds = 10000}) {
    toastification.dismissAll();
    toastification.show(
      overlayState: globalNavigatorKey.currentState?.overlay,
      type: ToastificationType.info,
      style: ToastificationStyle.flat,
      title: Text(message),
      autoCloseDuration: Duration(seconds: durationInSeconds),
      alignment: Alignment.bottomCenter,
    );
  }

  void toastSuccess({required String message}) {
    toastification.dismissAll();
    toastification.show(
      overlayState: globalNavigatorKey.currentState?.overlay,
      type: ToastificationType.success,
      style: ToastificationStyle.flat,
      title: Text(message),
      autoCloseDuration: Duration(seconds: 3),
      alignment: Alignment.bottomCenter,
    );
  }

  void toastError({required String message}) {
    toastification.dismissAll();
    toastification.show(
      overlayState: globalNavigatorKey.currentState?.overlay,
      type: ToastificationType.error,
      style: ToastificationStyle.flat,
      title: Text(message),
      autoCloseDuration: Duration(seconds: 3),
      alignment: Alignment.bottomCenter,
    );
  }
}
