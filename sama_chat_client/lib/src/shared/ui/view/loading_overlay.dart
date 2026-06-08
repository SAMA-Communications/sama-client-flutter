import 'package:flutter/material.dart';

import '../colors.dart';

class LoadingOverlay {
  OverlayEntry? _overlay;

  LoadingOverlay();

  void show(BuildContext context) {
    if (_overlay == null) {
      _overlay = OverlayEntry(
        builder: (context) => const ColoredBox(
          color: semiBlack,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
      Overlay.of(context).insert(_overlay!);
    }
  }

  void hide() {
    if (_overlay != null) {
      _overlay!.remove();
      _overlay = null;
    }
  }
}

void showTopBanner(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.of(context);

  messenger.clearMaterialBanners();

  messenger.showMaterialBanner(
    MaterialBanner(
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: black),
      ),
      backgroundColor: lightMallow,
      dividerColor: Colors.transparent,
      actions: const [SizedBox.shrink()],
    ),
  );

  Future.delayed(const Duration(seconds: 3), () {
    messenger.hideCurrentMaterialBanner();
  });
}
