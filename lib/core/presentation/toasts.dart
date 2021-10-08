import 'package:flash/flash.dart';
import 'package:flutter/material.dart';

Future<void> showNoConnectionToast(BuildContext context, String message) async {
  await showFlash(
      context: context,
      duration: const Duration(seconds: 4),
      builder: (context, controller) {
        return Flash.dialog(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          borderRadius: BorderRadius.circular(4),
          backgroundColor: Colors.black.withOpacity(0.7),
          controller: controller,
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        );
      });
}
