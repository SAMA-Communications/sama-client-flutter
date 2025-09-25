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
          child: ListTile(
            leading: Icon(Icons.replay_outlined),
            title: Text('one'),
          ),
        ),
        const PopupMenuItem<MessageMenuItem>(
            padding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
            value: MessageMenuItem.two,
            child: ListTile(
              leading: Icon(Icons.edit_outlined),
              title: Text('two'),
            )),
        const PopupMenuItem<MessageMenuItem>(
            padding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
            value: MessageMenuItem.etc,
            child: ListTile(
              leading: Icon(Icons.delete_forever_outlined),
              title: Text('etc.'),
            )),
      ],
      requestFocus: false,
      context: context,
    ).then((selected) {
      if (selected != null) onClickMenu?.call(selected);
    });
  }
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
