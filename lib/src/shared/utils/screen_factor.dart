import 'package:flutter/material.dart';

// the same as MediaQuery.of(context).size.width)
final double widthScreen =
    WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.width /
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

// the same as MediaQuery.of(context).size.height)
final double heightScreen =
    WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.height /
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

double keyboardHeight(BuildContext ctx) => MediaQuery.of(ctx).viewInsets.bottom;
