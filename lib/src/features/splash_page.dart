import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sama_client_flutter/src/features/conversations_list/conversations.dart';

import '../shared/ui/colors.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        toolbarHeight: min((MediaQuery.of(context).size.height / 4) + 20, 220),
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
            ),
          ],
        ),
      ),
      body: const CenterLoader(),
    );
  }
}
