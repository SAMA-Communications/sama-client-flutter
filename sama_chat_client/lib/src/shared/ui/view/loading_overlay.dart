import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../colors.dart';

class LoadingOverlay {
  LoadingOverlay._();

  static final LoadingOverlay instance = LoadingOverlay._();

  OverlayEntry? _overlayEntry;
  Timer? _autoHideTimer;

  bool get isShowing => _overlayEntry != null;

  void show(BuildContext context,
      {String? message, Duration duration = const Duration(seconds: 10)}) {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (_) => _LoaderWidget(message: message),
    );

    Overlay.of(
      context,
      rootOverlay: true,
    ).insert(_overlayEntry!);

    _autoHideTimer?.cancel();

    _autoHideTimer = Timer(duration, () {
      hide();
    });
  }

  void hide() {
    _autoHideTimer?.cancel();
    _autoHideTimer = null;

    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class _LoaderWidget extends StatelessWidget {
  final String? message;

  const _LoaderWidget({
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 2,
                sigmaY: 2,
              ),
              child: Container(
                color: black.withValues(alpha: 0.25),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message!,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
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
