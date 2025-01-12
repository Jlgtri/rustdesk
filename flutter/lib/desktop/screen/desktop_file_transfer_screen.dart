import 'package:flutter/material.dart';
import 'package:support/common.dart';
import 'package:support/desktop/pages/file_manager_tab_page.dart';
import 'package:provider/provider.dart';

/// multi-tab file transfer remote screen
class DesktopFileTransferScreen extends StatelessWidget {
  final Map<String, dynamic> params;

  const DesktopFileTransferScreen({Key? key, required this.params})
      : super(key: key);

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
        body: FileManagerTabPage(
          params: params,
        ),
      ),
    );
  }
}
