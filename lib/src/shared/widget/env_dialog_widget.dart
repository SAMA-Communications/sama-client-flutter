import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../api/utils/config.dart';
import '../../shared/auth/bloc/auth_bloc.dart';
import '../secure_storage.dart';
import '../ui/colors.dart';

class EnvDialogInput extends StatelessWidget {
  const EnvDialogInput({super.key});

  @override
  Widget build(BuildContext context) {
    EnvType? envType;
    return AlertDialog(
      title: const Center(
          child: Text('Environment switcher', style: TextStyle(fontSize: 22))),
      actionsPadding: const EdgeInsets.only(bottom: 8),
      contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      actionsAlignment: MainAxisAlignment.center,
      content: _EnvToggleButton((selectedType) => envType = selectedType),
      actions: [
        TextButton(
            child: const Text("Cancel"),
            onPressed: () {
              Navigator.pop(context, true);
            }),
        TextButton(
            child: const Text("Save"),
            onPressed: () {
              if (envType != null) {
                SecureStorage.instance.saveEnvironmentType(envType!);
                context
                    .read<AuthenticationBloc>()
                    .add(AuthenticationLogoutRequested());
              } else {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(content: Text('Make changes to update')),
                  );
              }
            })
      ],
    );
  }
}

class _EnvToggleButton extends StatefulWidget {
  const _EnvToggleButton(this.onEnvChanged);

  final ValueSetter<EnvType> onEnvChanged;

  @override
  _EnvToggleButtonState createState() => _EnvToggleButtonState();
}

class _EnvToggleButtonState extends State<_EnvToggleButton> {
  bool isToggledDev = false;

  @override
  void initState() {
    super.initState();
    SecureStorage.instance.getDevEnvironmentType().then((envType) {
      setState(() {
        isToggledDev = envType == EnvType.dev;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          setState(() {
            isToggledDev = !isToggledDev;
            widget.onEnvChanged(isToggledDev ? EnvType.dev : EnvType.prod);
          });
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 75,
              height: 35,
              decoration: BoxDecoration(
                color: isToggledDev ? slateBlue : semiBlack,
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    topLeft: Radius.circular(15)),
              ),
              child: const Center(
                child: Text(
                  'Dev',
                  style: TextStyle(color: white),
                ),
              ),
            ),
            Container(
              width: 75,
              height: 35,
              decoration: BoxDecoration(
                color: isToggledDev ? semiBlack : slateBlue,
                borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(15),
                    topRight: Radius.circular(15)),
              ),
              child: const Center(
                child: Text(
                  'Prod',
                  style: TextStyle(color: white),
                ),
              ),
            ),
          ],
        ));
  }
}
