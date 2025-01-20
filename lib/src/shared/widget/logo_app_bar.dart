import 'dart:math';

import 'package:flutter/material.dart';

import '../secure_storage.dart';
import '../ui/colors.dart';
import '../utils/screen_factor.dart';
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
          builder: (_) => AlertDialog(
            title: const Text('Erase all data'),
            content: const Text('Are you sure you want to erase all data?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  SecureStorage.instance.deleteAllData();
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              )
            ],
          ),
        ),
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
