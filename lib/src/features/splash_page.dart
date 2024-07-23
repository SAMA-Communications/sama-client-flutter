import 'package:flutter/material.dart';

import '../shared/ui/colors.dart';
import '../shared/widget/loaders.dart';
import '../shared/widget/logo_app_bar.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: white,
      appBar: LogoAppBar(),
      body: CenterLoader(),
    );
  }
}
