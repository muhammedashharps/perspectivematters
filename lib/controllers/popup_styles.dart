import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../pages/home_page.dart';

void showCustomDialog({required String title, required String middleText}) {
  Get.defaultDialog(
    title: title,
    middleText: middleText,
    backgroundColor: Colors.white,
    titleStyle: const TextStyle(
      color: Colors.black,
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    ),
    middleTextStyle: const TextStyle(
      color: Colors.black87,
      fontSize: 16,
      height: 1.5,
      letterSpacing: 0.15,
    ),
    radius: 16,
    contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
    titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
    barrierDismissible: false,
    actions: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton(
          onPressed: () {
            Get.offAll(
                  () => HomePage(),
              transition: Transition.downToUp,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 2,
          ),
          child: const Text(
            'OK',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    ],
  );
}
