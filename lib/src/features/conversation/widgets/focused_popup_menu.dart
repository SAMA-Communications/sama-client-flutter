import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../shared/ui/colors.dart';

class FocusedPopupMenuItem {
  Widget title;
  Icon? leadingIcon;
  Function onPressed;

  FocusedPopupMenuItem(
      {required this.title, this.leadingIcon, required this.onPressed});
}

class FocusedPopupMenu {
  final Widget child;
  final List<FocusedPopupMenuItem> menuItems;
  final BuildContext context;
  final bool stickToRight;

  FocusedPopupMenu(
      {required this.child,
      required this.menuItems,
      required this.context,
      required this.stickToRight});

  Future<void> show() async {
    RenderBox renderBox = context.findRenderObject()! as RenderBox;
    var childSize = renderBox.size;
    Offset offset = renderBox.localToGlobal(Offset.zero);
    var childOffset = Offset(offset.dx, offset.dy);

    await Navigator.push(
        context,
        PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 100),
            pageBuilder: (context, animation, secondaryAnimation) {
              animation = Tween(begin: 0.0, end: 1.0).animate(animation);
              return FadeTransition(
                  opacity: animation,
                  child: FocusedMenuDetails(
                    menuItems: menuItems,
                    childOffset: childOffset,
                    childSize: childSize,
                    stickToRight: stickToRight,
                    child: child,
                  ));
            },
            fullscreenDialog: true,
            opaque: false));
  }
}

class FocusedMenuDetails extends StatelessWidget {
  final Offset childOffset;
  final Size childSize;
  final List<FocusedPopupMenuItem> menuItems;
  final Widget child;
  final bool stickToRight;
  final menuItemHeight = 45.0;
  final maxMenuWidth = 140.0;
  final topMenuPadding = 8;
  final horizontalMenuPadding = 50;

  const FocusedMenuDetails(
      {required this.menuItems,
      required this.childOffset,
      required this.childSize,
      required this.stickToRight,
      required this.child,
      super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    final menuHeight = menuItems.length * menuItemHeight;
    final leftOffset = stickToRight
        ? childOffset.dx -
            maxMenuWidth +
            childSize.width -
            horizontalMenuPadding
        : childOffset.dx + horizontalMenuPadding;
    final topOffset =
        (childOffset.dy + menuHeight + childSize.height) < size.height
            ? childOffset.dy + childSize.height + topMenuPadding
            : childOffset.dy - menuHeight - topMenuPadding;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(
                  color: black.withValues(alpha: 0.7),
                ),
              )),
          Positioned(
            top: topOffset,
            left: leftOffset,
            child: TweenAnimationBuilder(
              duration: const Duration(milliseconds: 200),
              builder: (BuildContext context, value, Widget? child) {
                return Transform.scale(
                  scale: value,
                  alignment: Alignment.center,
                  child: child,
                );
              },
              tween: Tween(begin: 0.0, end: 1.0),
              child: Container(
                width: maxMenuWidth,
                height: menuHeight,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black38,
                          blurRadius: 10,
                          spreadRadius: 1)
                    ]),
                child: ListView.separated(
                  separatorBuilder: (context, index) =>
                      index == menuItems.length - 2
                          ? const Divider(height: 1)
                          : const SizedBox.shrink(),
                  itemCount: menuItems.length,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    FocusedPopupMenuItem item = menuItems[index];
                    return Material(
                        color: Colors.transparent,
                        child: InkWell(
                            splashColor: lightMallow,
                            onTap: () {
                              Navigator.pop(context);
                              item.onPressed();
                            },
                            child: Container(
                                alignment: Alignment.center,
                                height: menuItemHeight,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 14),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      item.title,
                                      if (item.leadingIcon != null) ...[
                                        item.leadingIcon!
                                      ]
                                    ],
                                  ),
                                ))));
                  },
                ),
              ),
            ),
          ),
          Positioned(
              top: childOffset.dy,
              left: childOffset.dx,
              child: AbsorbPointer(
                  absorbing: true,
                  child: SizedBox(
                      width: childSize.width,
                      height: childSize.height,
                      child: child))),
        ],
      ),
    );
  }
}
