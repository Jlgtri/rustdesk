import 'dart:io';

import 'package:flutter/material.dart';
import 'package:support/common.dart';
import 'package:support/desktop/pages/remote_tab_page.dart';
import 'package:support/models/platform_model.dart';
import 'package:support/models/state_model.dart';
import 'package:provider/provider.dart';

/// multi-tab desktop remote screen
class DesktopRemoteScreen extends StatelessWidget {
  final Map<String, dynamic> params;

  DesktopRemoteScreen({Key? key, required this.params}) : super(key: key) {
    bind.mainInitInputSource();
    stateGlobal.getInputSource(force: true);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: gFFI.ffiModel),
          ChangeNotifierProvider.value(value: gFFI.imageModel),
          ChangeNotifierProvider.value(value: gFFI.cursorModel),
          ChangeNotifierProvider.value(value: gFFI.canvasModel),
        ],
        child: Scaffold(
          // Set transparent background for padding the resize area out of the flutter view.
          // This allows the wallpaper goes through our resize area. (Linux only now).
          backgroundColor: Platform.isLinux ? Colors.transparent : null,
          body: ConnectionTabPage(
            params: params,
          ),
        ));
  }
}
