import 'package:flutter/material.dart';

enum MessageMenuItem { one, two, etc }

typedef MenuClickCallback = void Function(MessageMenuItem item);

//simple menu with offset, just sample (can be deleted)
class PopupMessageMenu {
  List<PopupMenuEntry<MessageMenuItem>>? items;

  final MenuClickCallback? onClickMenu;

  BuildContext context;

  PopupMessageMenu({required this.context, this.onClickMenu});

  Future<void> show(Offset offset) async {
    showMenu(
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy,
        MediaQuery.of(context).size.width - offset.dx,
        MediaQuery.of(context).size.height - offset.dy,
      ),
      items: [
        const PopupMenuItem<MessageMenuItem>(
          padding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
          value: MessageMenuItem.one,
          child: Text('Get summary'),
        ),
        const PopupMenuItem<MessageMenuItem>(
            padding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
            value: MessageMenuItem.two,
            child: Text('Change message tone')),
      ],
      requestFocus: false,
      context: context,
    ).then((selected) {
      if (selected != null) onClickMenu?.call(selected);
    });
  }

//
  // Future<void> show(RelativeRect position) async {
  //   showMenu(popUpAnimationStyle: AnimationStyle(
  //     curve: Curves.easeOutCubic, // Custom curve for the animation
  //     duration: const Duration(milliseconds: 500), // Custom duration
  //   ),
  //     position: position,
  //     items: [
  //       const PopupMenuItem<MessageMenuItem>(
  //         padding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
  //         value: MessageMenuItem.one,
  //         child: Text('Get summary'),
  //       ),
  //       const PopupMenuItem<MessageMenuItem>(
  //           padding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
  //           value: MessageMenuItem.two,
  //           child: Text('Change message tone'),),
  //     ],
  //     requestFocus: false,
  //     context: context,
  //   ).then((selected) {
  //     if (selected != null) onClickMenu?.call(selected);
  //   });
  // }
}

/*
usage
GestureDetector(
            onLongPressStart: (details) {
              PopupMessageMenu(
                  context: context,
                  onClickMenu: (MessageMenuItem item) {
                    switch (item) {
                      case MessageMenuItem.one:
                        break;
                      case MessageMenuItem.two:
                        break;
                      case MessageMenuItem.etc:
                        break;
                    }
                  }).show(details.globalPosition);
            },
 */
