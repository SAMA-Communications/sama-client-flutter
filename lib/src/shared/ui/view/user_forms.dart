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
          borderRadius: BorderRadius.circular(5.0),
        ),
        padding: const EdgeInsets.all(4.0),
        height: 85.0,
        width: 85.0,
        child: Center(child: () {
          if (avatar == null || avatar!.isEmpty) {
            return const Icon(
              Icons.image_outlined,
              color: dullGray,
              size: 50.0,
            );
          } else {
            return Image.network(
              avatar!,
              height: 75.0,
              width: 75.0,
              fit: BoxFit.cover,
            );
          }
        }()));
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
          color: lightWhite,
          border: Border.all(
            color: lightWhite,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(Icons.local_phone_outlined, color: dullGray, size: 25),
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
          borderRadius: BorderRadius.circular(10),
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
