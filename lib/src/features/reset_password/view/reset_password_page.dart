import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../repository/authentication/authentication_repository.dart';
import '../../../shared/ui/colors.dart';
import '../../../shared/widget/logo_app_bar.dart';
import '../bloc/reset_password_bloc.dart';
import 'send_email_form.dart';
import 'send_otp_form.dart';
import 'send_reset_password_form.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

  static BlocProvider route() {
    return BlocProvider<ResetPasswordBloc>(
        create: (context) {
          return ResetPasswordBloc(
              authenticationRepository:
                  RepositoryProvider.of<AuthenticationRepository>(context));
        },
        child: const ResetPasswordPage());
  }

  static const List<Widget> forms = <Widget>[
    SendEmailForm(),
    SendOtpForm(),
    SendResetPasswordForm(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ResetPasswordBloc, ResetPasswordState>(
        builder: (BuildContext context, state) {
      return Scaffold(
          backgroundColor: white,
          appBar: LogoAppBar(onPressed: () {
            if (state.currentForm == 0) {
              Navigator.of(context).pop();
            } else {
              context.read<ResetPasswordBloc>().add(const OnBackCurrentForm());
            }
          }),
          body: Container(
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: SingleChildScrollView(
                child: forms[state.currentForm],
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
              child: SizedBox(
            height: 18,
            child: BottomNavigationBar(
              backgroundColor: white,
              elevation: 0,
              currentIndex: state.currentForm,
              onTap: null,
              selectedFontSize: 0,
              unselectedFontSize: 0,
              items: [
                bottomNavigationBarItemLine(),
                bottomNavigationBarItemLine(),
                bottomNavigationBarItemLine(),
              ],
            ),
          )));
    });
  }

  BottomNavigationBarItem bottomNavigationBarItemLine() {
    return BottomNavigationBarItem(
      icon: Container(
        alignment: Alignment.topCenter,
        height: 2.0,
        width: 100.0,
        color: lightMallow,
      ),
      activeIcon: Container(
        height: 2.0,
        width: 100.0,
        color: slateBlue,
      ),
      label: '',
    );
  }
}
