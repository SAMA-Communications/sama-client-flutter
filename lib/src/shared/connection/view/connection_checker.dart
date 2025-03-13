import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/connection_bloc.dart';

class ConnectionChecker extends StatelessWidget {
  final Widget child;

  const ConnectionChecker({super.key, required this.child});

  @override
  Widget build(context) {
    return BlocBuilder<ConnectionBloc, ConnectionState>(
        builder: (BuildContext context, state) {
      var absorbPointer = context.read<ConnectionBloc>().state.status !=
          ConnectionStatus.connected;
      return Listener(
          onPointerDown: (event) {
            if (absorbPointer) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Oops! You need to be online to perform this action')),
                );
            }
          },
          child: AbsorbPointer(
            absorbing: absorbPointer,
            child: child,
          ));
    });
  }
}

connectionChecker(BuildContext ctx, Function() func) {
  if (ctx.read<ConnectionBloc>().state.status == ConnectionStatus.connected) {
    func.call();
  } else {
    ScaffoldMessenger.of(ctx)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
            content:
                Text('Oops! You need to be online to perform this action')),
      );
  }
}
