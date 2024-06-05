import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            context.go(chatListScreenPath);
          },
          child: const Text('Go to Chats'),
        ),
      ),
    );
  }
}