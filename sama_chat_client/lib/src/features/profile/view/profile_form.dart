import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../features/profile/bloc/profile_bloc.dart';
import '../../../shared/auth/bloc/auth_bloc.dart';
import '../../../shared/connection/view/connection_checker.dart';
import '../../../shared/ui/colors.dart';
import '../../../shared/ui/view/user_forms.dart';
import '../../../shared/utils/screen_factor.dart';
import '../models/models.dart';

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
        child: const ProfileCard());
  }
}

class AvatarNameTile extends StatelessWidget {
  const AvatarNameTile({super.key});

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
        child: ListTile(
      titleAlignment: ListTileTitleAlignment.top,
      title: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: _UserAvatar(),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: _UserFullName(),
      ),
    ));
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Padding(
      padding: EdgeInsets.only(bottom: Platform.isIOS ? 0.0 : 4.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Stack(
            children: [
              _UserData(),
              const Align(
                  alignment: Alignment.bottomRight, child: _LogoutForm()),
            ],
          ),
        ),
      ),
    ));
  }
}

class _UserData extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Align(
        alignment: Alignment(0, -0.5),
        child: IntrinsicHeight(
            child: Stack(
          children: [
            Card(
              color: paleMallow,
              margin: EdgeInsets.only(top: 40),
              child: Padding(
                padding: EdgeInsets.only(top: 100, left: 4, right: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ConnectionChecker(child: _UsernameForm()),
                    SizedBox(height: columnItemMargin),
                    ConnectionChecker(child: _PhoneForm()),
                    SizedBox(height: columnItemMargin),
                    ConnectionChecker(child: _EmailForm()),
                    SizedBox(height: columnItemMargin),
                    ConnectionChecker(child: _AccountForm()),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment(0, -1.1),
              child: ConnectionChecker(child: AvatarNameTile()),
            ),
          ],
        )));
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
              child: AvatarForm(
                avatar: state.userAvatar.value!,
              ));
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
          return TextButton(
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
            child: Column(mainAxisSize: MainAxisSize.min, children: [
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
                    fontSize: 18,
                    color: signalBlack,
                    fontWeight: state.userLastname.value.isEmpty
                        ? FontWeight.w200
                        : FontWeight.normal),
                overflow: TextOverflow.ellipsis,
              ),
            ]),
          );
        });
  }
}

class _UsernameForm extends StatelessWidget {
  const _UsernameForm();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
        buildWhen: (previous, current) =>
            previous.userLogin != current.userLogin,
        builder: (context, state) {
          return UsernameForm(userLogin: state.userLogin);
        });
  }
}

class _PhoneForm extends StatelessWidget {
  const _PhoneForm();

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
              child: UserPhoneForm(
                  userPhone: state.userPhone.value,
                  userPhoneStub: 'Enter your phone number'));
        });
  }
}

class _EmailForm extends StatelessWidget {
  const _EmailForm();

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
              child: UserEmailForm(
                  userEmail: state.userEmail.value,
                  userEmailStub: 'Enter your email address'));
        });
  }
}

class _AccountForm extends StatelessWidget {
  const _AccountForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (_) {
                      return BlocProvider.value(
                        value: BlocProvider.of<ProfileBloc>(context),
                        child: _ChangePasswordInput(),
                      );
                    });
              },
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
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (_) {
                      return BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                          child: AlertDialog(
                            title: const Text('Delete account',
                                style: TextStyle(fontSize: 20)),
                            content: const Text(
                                'Are you sure you want to delete this user?',
                                style: TextStyle(fontSize: 16)),
                            actionsAlignment: MainAxisAlignment.spaceAround,
                            actions: <Widget>[
                              TextButton(
                                child: const Text("Cancel"),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              TextButton(
                                child: const Text("Confirm"),
                                onPressed: () {
                                  context
                                      .read<AuthenticationBloc>()
                                      .add(AuthenticationSignOutRequested());
                                },
                              ),
                            ],
                          ));
                    });
              },
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

class _LogoutForm extends StatelessWidget {
  const _LogoutForm();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        context.read<AuthenticationBloc>().add(AuthenticationLogoutRequested());
      },
      icon: const Icon(Icons.exit_to_app_outlined, color: dullGray, size: 25),
      style: TextButton.styleFrom(
          backgroundColor: paleMallow, alignment: Alignment.centerLeft),
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
                    onSubmitted: (value) =>
                        ScaffoldMessenger.of(context).hideCurrentSnackBar(),
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
                      errorText: state.userFirstname.displayError ==
                              UserFirstnameValidationError.empty
                          ? 'user first name is empty'
                          : state.userFirstname.displayError ==
                                  UserFirstnameValidationError.outOfRange
                              ? 'user can\'t to add more than 20 symbols'
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
                    onSubmitted: (value) =>
                        ScaffoldMessenger.of(context).hideCurrentSnackBar(),
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
                      errorText: state.userLastname.displayError ==
                              UserLastnameValidationError.empty
                          ? 'user last name is empty'
                          : state.userLastname.displayError ==
                                  UserLastnameValidationError.outOfRange
                              ? 'user can\'t to add more than 20 symbols'
                              : null,
                    ),
                  ),
                ),
              ]),
              actionsAlignment: MainAxisAlignment.spaceAround,
              actions: _formActions(context));
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
              contentPadding: const EdgeInsets.fromLTRB(26, 16, 16, 8),
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
                    onSubmitted: (value) =>
                        ScaffoldMessenger.of(context).hideCurrentSnackBar(),
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
                          ? 'The phone range 3 to 15 digits.'
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
                    onSubmitted: (value) =>
                        ScaffoldMessenger.of(context).hideCurrentSnackBar(),
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
                          ? 'The format of the email is incorrect.'
                          : null,
                    ),
                  ),
                ),
              ]),
              actionsAlignment: MainAxisAlignment.spaceAround,
              actions: _formActions(context));
        });
  }
}

class _ChangePasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var currentPswTxt = TextEditingController();
    var newPswTxt = TextEditingController();

    return BlocBuilder<ProfileBloc, ProfileState>(
        buildWhen: (previous, current) =>
            previous.userPassword != current.userPassword,
        builder: (context, state) {
          return AlertDialog(
              title: const Text('Change password'),
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
                    keyboardType: TextInputType.visiblePassword,
                    controller: currentPswTxt,
                    style: const TextStyle(fontSize: 18),
                    onSubmitted: (value) =>
                        ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                    onChanged: (currentPsw) => context.read<ProfileBloc>().add(
                        ProfilePasswordChanged(currentPsw, newPswTxt.text)),
                    obscureText: true,
                    obscuringCharacter: '*',
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(bottom: 4),
                      label: Row(
                        children: [
                          Icon(
                            Icons.lock_open_outlined,
                            size: 16,
                            color: dullGray,
                          ),
                          Text(
                            ' Enter current password:',
                            style: TextStyle(color: dullGray, fontSize: 16),
                          )
                        ],
                      ),
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
                    keyboardType: TextInputType.visiblePassword,
                    style: const TextStyle(fontSize: 18),
                    controller: newPswTxt,
                    onSubmitted: (value) =>
                        ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                    onChanged: (newPsw) => context.read<ProfileBloc>().add(
                        ProfilePasswordChanged(currentPswTxt.text, newPsw)),
                    obscureText: true,
                    obscuringCharacter: '*',
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.only(bottom: 4),
                      label: const Row(
                        children: [
                          Icon(
                            Icons.lock_outline,
                            size: 16,
                            color: dullGray,
                          ),
                          Text(
                            ' Enter a new password:',
                            style: TextStyle(color: dullGray, fontSize: 16),
                          )
                        ],
                      ),
                      errorMaxLines: 2,
                      errorText: state.userPassword.value.isNotEmpty &&
                              state.userPassword.displayError ==
                                  UserPasswordValidationError.outOfRange
                          ? 'The password length must be in the range from 3 to 40.'
                          : null,
                    ),
                  ),
                ),
              ]),
              actionsAlignment: MainAxisAlignment.spaceAround,
              actions: _formActions(context));
        });
  }
}

List<Widget> _formActions(BuildContext context) {
  return [
    TextButton(
      onPressed: () {
        context.read<ProfileBloc>().add(ProfileResetChanges());
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        Navigator.pop(context, 'Cancel');
      },
      child: const Text('Cancel'),
    ),
    TextButton(
      onPressed: () {
        if (context.read<ProfileBloc>().state.isValid) {
          context.read<ProfileBloc>().add(ProfileSubmitted());
          Navigator.pop(context, 'Save');
        } else {
          var content = 'Please make changes to the data.';
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              keyboardIsOpen()
                  ? SnackBar(
                      content: Text(content),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      margin: EdgeInsets.only(
                          bottom: keyboardHeightCtx(context) -
                              (Platform.isIOS ? navBarHeight(context) : 0.0)))
                  : SnackBar(
                      content: Text(content),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.fixed),
            );
        }
      },
      child: const Text('Save'),
    ),
  ];
}
