
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            context.go(loginScreenPath);
          },
          child: const Text('Go to Login'),
        ),
      ),
    );
  }
}