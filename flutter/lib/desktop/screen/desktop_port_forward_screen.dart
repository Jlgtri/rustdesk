import 'package:flutter/material.dart';
import 'package:support/common.dart';
import 'package:support/desktop/pages/port_forward_tab_page.dart';
import 'package:provider/provider.dart';

/// multi-tab file port forward screen
class DesktopPortForwardScreen extends StatelessWidget {
  final Map<String, dynamic> params;

  const DesktopPortForwardScreen({Key? key, required this.params})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: gFFI.ffiModel),
      ],
      child: Scaffold(
        body: PortForwardTabPage(
          params: params,
        ),
      ),
    );
  }
}
