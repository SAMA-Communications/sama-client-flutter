import 'dart:math';

import 'package:flutter/material.dart';

import '../ui/colors.dart';
import '../utils/screen_factor.dart';
import 'env_dialog_widget.dart';
import 'multi_gesture_detector.dart';

class LogoAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LogoAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
        flexibleSpace: FlexibleSpaceBar(
      background: MultiGestureDetector(
        taps: 5,
        onTap: () => showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return const EnvDialogInput();
            }),
        child: Stack(
          children: [
            Image.asset(
              'assets/images/sama_background.png',
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 46,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  color: white,
                ),
              ),
            )
          ],
        ),
      ),
    ));
  }

  @override
  Size get preferredSize => Size.fromHeight(min((heightScreen / 4) + 20, 220));
}
