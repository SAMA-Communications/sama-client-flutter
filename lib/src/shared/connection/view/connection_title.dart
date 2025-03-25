import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/connection/bloc/connection_bloc.dart';

class ConnectionTitle extends StatelessWidget {
  final Color color;
  final Widget title;

  const ConnectionTitle({super.key, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectionBloc, ConnectionState>(
        builder: (BuildContext context, state) {
      if (state.status == ConnectionStatus.connected) {
        return title;
      }
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 10,
        children: [
          Transform.scale(
              scale: 0.75,
              child: CircularProgressIndicator(color: color, strokeWidth: 3.0)),
          _getTitleWidget(state),
        ],
      );
    });
  }

  Widget _getTitleWidget(ConnectionState state) {
    String title;
    double fontSize = 22.0;
    switch (state.status) {
      case ConnectionStatus.connecting:
        title = 'Connecting…';
        break;
      case ConnectionStatus.connected:
        title = 'Connected';
        break;
      case ConnectionStatus.disconnected:
      case ConnectionStatus.offline:
        title = 'Waiting for network';
        fontSize = 20.0;
    }
    return Text(title, style: TextStyle(color: color, fontSize: fontSize));
  }
}
