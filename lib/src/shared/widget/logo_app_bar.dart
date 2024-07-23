import 'dart:math';

import 'package:flutter/material.dart';

import '../../api/utils/screen_factor.dart';
import '../ui/colors.dart';

class LogoAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LogoAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      flexibleSpace: Stack(
        children: [
          Image.asset(
            'assets/images/sama_background.png',
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 24,
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
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(min((heightScreen / 4) + 20, 220));
}
