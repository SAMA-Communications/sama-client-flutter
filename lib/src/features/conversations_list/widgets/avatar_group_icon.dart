import 'package:flutter/material.dart';

import '../../../api/api.dart';
import '../../../shared/ui/colors.dart';

class AvatarGroupIcon extends StatelessWidget {
  const AvatarGroupIcon(this.avatar, {super.key});

  final Avatar? avatar;
  final Size size = const Size(55, 60);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: black,
          borderRadius: BorderRadius.circular(5.0),
        ),
        padding: const EdgeInsets.all(4.0),
        height: size.height,
        width: size.width,
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5.0),
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
