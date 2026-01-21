import 'package:flutter/material.dart';

import '../colors.dart';

const columnItemMargin = 10.0;

class AvatarForm extends StatelessWidget {
  final String? avatar;

  const AvatarForm({super.key, required this.avatar});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: black,
          shape: BoxShape.circle,
          border: Border.all(color: white, width: 2),
            boxShadow: [
              BoxShadow(
                color: black.withValues(alpha: 0.5),
                spreadRadius: 3,
                blurRadius: 7,
                offset: const Offset(0, 3), // Controls the shadow's position
              ),
            ],
        ),
        height: 85.0,
        width: 85.0,
        child: Center(child: () {
          if (avatar == null || avatar!.isEmpty) {
            return _defaultIcon();
          } else {
            return ClipOval(
                child: Image.network(
              avatar!,
              height: 85.0,
              width: 85.0,
              fit: BoxFit.cover,
              errorBuilder: (BuildContext context, Object exception,
                  StackTrace? stackTrace) {
                return _defaultIcon();
              },
            ));
          }
        }()));
  }

  Widget _defaultIcon() {
    return const Icon(
      Icons.image_outlined,
      color: dullGray,
      size: 50.0,
    );
  }
}

class UsernameForm extends StatelessWidget {
  final String? userLogin;

  const UsernameForm({super.key, required this.userLogin});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(Icons.person_2_outlined, color: dullGray, size: 25),
                Text(
                  ' Username',
                  style: TextStyle(fontWeight: FontWeight.w300),
                ),
              ],
            ),
            Text(
              userLogin ?? "",
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
            ),
          ],
        ));
  }
}

class UserPhoneForm extends StatelessWidget {
  final String? userPhone;
  final String userPhoneStub;

  const UserPhoneForm(
      {super.key, required this.userPhone, this.userPhoneStub = ''});

  @override
  Widget build(BuildContext context) {
    return Ink(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: white,
          border: Border.all(
            color: lightWhite,
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.local_phone_outlined, color: dullGray, size: 26),
                Text(
                  ' Mobile phone',
                  style: TextStyle(fontWeight: FontWeight.w300),
                ),
              ],
            ),
            Text(
              userPhone == null ? userPhoneStub : userPhone!,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      userPhone == null ? FontWeight.w200 : FontWeight.normal),
            ),
          ],
        ));
  }
}

class UserEmailForm extends StatelessWidget {
  final String? userEmail;
  final String userEmailStub;

  const UserEmailForm(
      {super.key, required this.userEmail, this.userEmailStub = ''});

  @override
  Widget build(BuildContext context) {
    return Ink(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: lightWhite,
          border: Border.all(
            color: lightWhite,
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(Icons.email_outlined, color: dullGray, size: 25),
                Text(
                  ' Email address',
                  style: TextStyle(fontWeight: FontWeight.w300),
                ),
              ],
            ),
            Text(
              userEmail == null ? userEmailStub : userEmail!,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      userEmail == null ? FontWeight.w200 : FontWeight.normal),
            ),
          ],
        ));
  }
}
