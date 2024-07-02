import 'package:flutter/material.dart';

class AvatarGroupIcon extends StatelessWidget {
  const AvatarGroupIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(5.0),
        ),
        padding: const EdgeInsets.all(4.0),
        margin: const EdgeInsets.only(bottom: 8.0),
        height: 55.0,
        width: 50.0,
        child: const Center(
          child: Icon(
            Icons.people_alt_outlined,
            size: 28.0,
          ),
        ));
  }
}
