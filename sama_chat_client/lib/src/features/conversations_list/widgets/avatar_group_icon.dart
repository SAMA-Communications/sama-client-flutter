import 'package:flutter/material.dart';

import '../../../db/models/avatar_model.dart';
import '../../../shared/ui/colors.dart';

class AvatarGroupIcon extends StatelessWidget {
  const AvatarGroupIcon(this.avatar, this.name, {super.key});

  final AvatarModel? avatar;
  final String name;
  final Size size = const Size(55, 60);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: getAvatarColor(name),
          shape: BoxShape.circle,
        ),
        height: size.height,
        width: size.width,
        child: Center(
          child: ClipOval(
            child: avatar?.imageUrl != null
                ? Image.network(
                    avatar!.imageUrl!,
                    height: size.height,
                    width: size.width,
                    fit: BoxFit.cover,
                  )
                : const Icon(
                    Icons.people_alt_outlined,
                    size: 30.0,
                  ),
          ),
        ));
  }
}
