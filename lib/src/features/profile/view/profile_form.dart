import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:go_router/go_router.dart';

import '../../../features/profile/bloc/profile_bloc.dart';
import '../../../shared/auth/bloc/auth_bloc.dart';
import '../../../shared/ui/colors.dart';
import '../models/models.dart';

const columnItemMargin = 10.0;

class ProfileForm extends StatelessWidget {
  const ProfileForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state.status.isFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(state.errorMessage ?? '')),
              );
          } else if (state.status.isSuccess &&
              state.informationMessage != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(state.informationMessage ?? '')),
              );
          }
        },
        child: const Column(mainAxisSize: MainAxisSize.min, children: [
          HeaderCard(),
          FooterCard(),
        ]));
  }
}

class HeaderCard extends StatelessWidget {
  const HeaderCard({super.key});

  final arrowBackSize = 30.0;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        titleAlignment: ListTileTitleAlignment.top,
        leading: IconButton(
          style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap),
          icon: Icon(Icons.arrow_back_outlined,
              color: signalBlack, size: arrowBackSize),
          onPressed: () {
            context.pop();
          },
        ),
        title: Center(
          child: Padding(
            padding: EdgeInsets.only(right: arrowBackSize, top: 8),
            child: _UserAvatar(),
          ),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(right: arrowBackSize, bottom: 4),
          child: _UserFullName(),
        ),
      ),
    );
  }
}

class FooterCard extends StatelessWidget {
  const FooterCard({super.key});

  final arrowBackSize = 30.0;

  @override
  Widget build(BuildContext context) {
    return const Expanded(
      child: Padding(
        padding: EdgeInsets.only(bottom: 4),
        child: SizedBox(
          width: double.infinity,
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  UsernameForm(),
                  SizedBox(height: columnItemMargin),
                  MobileForm(),
                  SizedBox(height: columnItemMargin),
                  EmailForm(),
                  SizedBox(height: columnItemMargin),
                  AccountForm(),
                  Expanded(
                      child: Align(
                          alignment: Alignment.bottomRight,
                          child: LogoutForm()))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
        buildWhen: (previous, current) =>
            previous.userAvatar != current.userAvatar,
        builder: (context, state) {
          return GestureDetector(
              onTap: () =>
                  context.read<ProfileBloc>().add(ProfileAvatarPicked()),
              child: Container(
                  decoration: BoxDecoration(
                    color: black,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  padding: const EdgeInsets.all(4.0),
                  height: 75.0,
                  width: 75.0,
                  child: Center(child: () {
                    if (state.userAvatar.value == null) {
                      return const Icon(
                        Icons.image_outlined,
                        color: dullGray,
                        size: 50.0,
                      );
                    } else {
                      return Image.file(
                        state.userAvatar.value!,
                        height: 75.0,
                        width: 75.0,
                        fit: BoxFit.cover,
                      );
                    }
                  }())));
        });
  }
}

class _UserFullName extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
        buildWhen: (previous, current) =>
            previous.userFirstname != current.userFirstname &&
                current.userFirstname.isPure ||
            previous.userLastname != current.userLastname &&
                current.userLastname.isPure,
        builder: (context, state) {
          return Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (_) {
                        return BlocProvider.value(
                          value: BlocProvider.of<ProfileBloc>(context),
                          child: const NameDialogInput(),
                        );
                      });
                },
                style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.center),
                child: Column(children: [
                  Text(
                    state.userFirstname.value.isEmpty
                        ? "First name"
                        : state.userFirstname.value,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: state.userFirstname.value.isEmpty
                            ? FontWeight.w200
                            : FontWeight.bold,
                        color: signalBlack),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    state.userLastname.value.isEmpty
                        ? "Last name"
                        : state.userLastname.value,
                    style: TextStyle(
                        color: signalBlack,
                        fontWeight: state.userLastname.value.isEmpty
                            ? FontWeight.w200
                            : FontWeight.normal),
                    overflow: TextOverflow.ellipsis,
                  ),
                ]),
              ));
        });
  }
}

class UsernameForm extends StatelessWidget {
  const UsernameForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
        buildWhen: (previous, current) =>
            previous.userLogin != current.userLogin,
        builder: (context, state) {
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
                    context.read<ProfileBloc>().state.userLogin,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.normal),
                  ),
                ],
              ));
        });
  }
}

class MobileForm extends StatelessWidget {
  const MobileForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
        buildWhen: (previous, current) =>
            previous.userPhone != current.userPhone && current.userPhone.isPure,
        builder: (context, state) {
          return InkWell(
              splashColor: lightMallow,
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (_) {
                      return BlocProvider.value(
                        value: BlocProvider.of<ProfileBloc>(context),
                        child: const InfoDialogInput(),
                      );
                    });
              },
              child: Ink(
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
                          Icon(Icons.local_phone_outlined,
                              color: dullGray, size: 25),
                          Text(
                            ' Mobile phone',
                            style: TextStyle(fontWeight: FontWeight.w300),
                          ),
                        ],
                      ),
                      Text(
                        state.userPhone.value.isEmpty
                            ? 'Enter your phone number'
                            : state.userPhone.value,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: state.userPhone.value.isEmpty
                                ? FontWeight.w200
                                : FontWeight.normal),
                      ),
                    ],
                  )));
        });
  }
}

class EmailForm extends StatelessWidget {
  const EmailForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
        buildWhen: (previous, current) =>
            previous.userEmail != current.userEmail && current.userEmail.isPure,
        builder: (context, state) {
          return InkWell(
              splashColor: lightMallow,
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (_) {
                      return BlocProvider.value(
                        value: BlocProvider.of<ProfileBloc>(context),
                        child: const InfoDialogInput(),
                      );
                    });
              }, // Handle your callback
              child: Ink(
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
                        state.userEmail.value.isEmpty
                            ? 'Enter your email address'
                            : state.userEmail.value,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: state.userEmail.value.isEmpty
                                ? FontWeight.w200
                                : FontWeight.normal),
                      ),
                    ],
                  )));
        });
  }
}

class AccountForm extends StatelessWidget {
  const AccountForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.lock_reset_outlined,
                  color: dullGray, size: 25),
              style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  alignment: Alignment.centerLeft),
              label: const Text(
                'Change password',
                style: TextStyle(fontWeight: FontWeight.w300),
              ),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.delete_forever_outlined,
                  color: red, size: 25),
              style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  alignment: Alignment.centerLeft),
              label: const Text(
                'Delete account',
                style: TextStyle(fontWeight: FontWeight.w300, color: red),
              ),
            ),
          ],
        ));
  }
}

class LogoutForm extends StatelessWidget {
  const LogoutForm({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        context.read<AuthenticationBloc>().add(AuthenticationLogoutRequested());
      },
      icon: const Icon(Icons.exit_to_app_outlined, color: dullGray, size: 25),
      style: TextButton.styleFrom(
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          alignment: Alignment.centerLeft),
      label: const Text(
        'Logout',
        style: TextStyle(fontWeight: FontWeight.w300),
      ),
    );
  }
}

class NameDialogInput extends StatelessWidget {
  const NameDialogInput({super.key});

  @override
  Widget build(BuildContext context) {
    var firstNameTxt = TextEditingController()
      ..text = context.read<ProfileBloc>().state.userFirstname.value;
    var lastNameTxt = TextEditingController()
      ..text = context.read<ProfileBloc>().state.userLastname.value;

    return BlocBuilder<ProfileBloc, ProfileState>(
        buildWhen: (previous, current) =>
            previous.userFirstname != current.userFirstname ||
            previous.userLastname != current.userLastname,
        builder: (context, state) {
          return AlertDialog(
            title: const Text('Edit your name'),
            actionsPadding: const EdgeInsets.only(bottom: 8),
            contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  color: gainsborough,
                ),
                child: TextField(
                  keyboardType: TextInputType.text,
                  controller: firstNameTxt,
                  style: const TextStyle(fontSize: 18),
                  onChanged: (firstName) => context
                      .read<ProfileBloc>()
                      .add(ProfileUserFirstnameChanged(firstName)),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.only(bottom: 4),
                    label: const Text(
                      'First name',
                      style: TextStyle(color: dullGray, fontSize: 16),
                    ),
                    errorText: !state.userFirstname.isPure &&
                            state.userFirstname.displayError ==
                                UserFirstnameValidationError.empty
                        ? 'Please make changes to the data.'
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: columnItemMargin),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  color: gainsborough,
                ),
                child: TextField(
                  keyboardType: TextInputType.text,
                  controller: lastNameTxt,
                  style: const TextStyle(fontSize: 18),
                  onChanged: (lastName) => context
                      .read<ProfileBloc>()
                      .add(ProfileUserLastnameChanged(lastName)),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.only(bottom: 4),
                    label: const Text(
                      'Last name',
                      style: TextStyle(color: dullGray, fontSize: 16),
                    ),
                    errorText: !state.userLastname.isPure &&
                            state.userLastname.displayError ==
                                UserLastnameValidationError.empty
                        ? 'The format of the email address is incorrect.'
                        : null,
                  ),
                ),
              ),
            ]),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  context.read<ProfileBloc>().add(ProfileResetChanges());
                  Navigator.pop(context, 'Cancel');
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (state.isValid) {
                    context.read<ProfileBloc>().add(ProfileSubmitted());
                    Navigator.pop(context, 'Save');
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        });
  }
}

class InfoDialogInput extends StatelessWidget {
  const InfoDialogInput({super.key});

  @override
  Widget build(BuildContext context) {
    var phoneTxt = TextEditingController()
      ..text = context.read<ProfileBloc>().state.userPhone.value;
    var emailTxt = TextEditingController()
      ..text = context.read<ProfileBloc>().state.userEmail.value;

    return BlocBuilder<ProfileBloc, ProfileState>(
        buildWhen: (previous, current) =>
            previous.userPhone != current.userPhone ||
            previous.userEmail != current.userEmail,
        builder: (context, state) {
          return AlertDialog(
            title: const Text('Edit personal info'),
            actionsPadding: const EdgeInsets.only(bottom: 8),
            contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  color: gainsborough,
                ),
                child: TextField(
                  keyboardType: TextInputType.phone,
                  controller: phoneTxt,
                  style: const TextStyle(fontSize: 18),
                  onChanged: (phone) => context
                      .read<ProfileBloc>()
                      .add(ProfilePhoneChanged(phone)),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.only(bottom: 4),
                    label: const Row(
                      children: [
                        Icon(
                          Icons.local_phone_outlined,
                          size: 16,
                          color: dullGray,
                        ),
                        Text(
                          ' Mobile phone',
                          style: TextStyle(color: dullGray, fontSize: 16),
                        )
                      ],
                    ),
                    errorText: state.userPhone.displayError ==
                            UserPhoneValidationError.outOfRange
                        ? 'The phone number should be 3 to 15 digits in length.'
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: columnItemMargin),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  color: gainsborough,
                ),
                child: TextField(
                  keyboardType: TextInputType.emailAddress,
                  controller: emailTxt,
                  style: const TextStyle(fontSize: 18),
                  onChanged: (phone) => context
                      .read<ProfileBloc>()
                      .add(ProfileEmailChanged(phone)),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.only(bottom: 4),
                    label: const Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          size: 16,
                          color: dullGray,
                        ),
                        Text(
                          ' Email address',
                          style: TextStyle(color: dullGray, fontSize: 16),
                        )
                      ],
                    ),
                    errorText: state.userEmail.displayError ==
                            UserEmailValidationError.incorrect
                        ? 'The format of the email address is incorrect.'
                        : null,
                  ),
                ),
              ),
            ]),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  context.read<ProfileBloc>().add(ProfileResetChanges());
                  Navigator.pop(context, 'Cancel');
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (state.isValid) {
                    context.read<ProfileBloc>().add(ProfileSubmitted());
                    Navigator.pop(context, 'Save');
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        });
  }
}
