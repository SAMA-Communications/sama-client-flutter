import 'dart:ui';

import 'package:flutter/material.dart';

// the same as MediaQuery.of(context).size.width)
final double screenWidth =
    WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.width /
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

// the same as MediaQuery.of(context).size.height)
final double screenHeight =
    WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.height /
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

double keyboardHeightCtx(BuildContext ctx) =>
    MediaQuery.of(ctx).viewInsets.bottom;

double keyboardHeight() {
  var window = PlatformDispatcher.instance.views.first;
  final viewInsets = EdgeInsets.fromViewPadding(
    window.viewInsets,
    window.devicePixelRatio,
  );
  return viewInsets.bottom;
}

bool keyboardIsOpen(BuildContext ctx) => keyboardHeightCtx(ctx) != 0;

void hideKeyboard() => FocusManager.instance.primaryFocus?.unfocus();
