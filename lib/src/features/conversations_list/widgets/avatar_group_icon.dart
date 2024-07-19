import 'package:flutter/material.dart';

import '../../../shared/ui/colors.dart';

class AvatarGroupIcon extends StatelessWidget {
  const AvatarGroupIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: black,
          borderRadius: BorderRadius.circular(5.0),
        ),
        padding: const EdgeInsets.all(4.0),
        height: 60.0,
        width: 55.0,
        child: const Center(
          child: Icon(
            Icons.people_alt_outlined,
            size: 30.0,
          ),
        ));
  }
}
