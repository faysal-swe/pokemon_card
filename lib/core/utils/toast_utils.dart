import 'package:flutter/material.dart';

final GlobalKey<ScaffoldMessengerState> appMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class AppToast {
  static void show(String message, {BuildContext? context}) {
    final messenger = (context != null && context.mounted)
        ? ScaffoldMessenger.maybeOf(context)
        : appMessengerKey.currentState;

    if (messenger == null) return;

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF2B2D42),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
