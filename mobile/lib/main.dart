import 'package:flutter/cupertino.dart';

import './pages/home_page.dart';
import './bluetooth/ble_manager.dart';
import './bluetooth/ble_scope.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FStopApp());
}

class FStopApp extends StatefulWidget {
  const FStopApp({super.key});

  @override
  State<FStopApp> createState() => _FStopAppState();
}

class _FStopAppState extends State<FStopApp> {
  late final BleManager _bleManager;

  @override
  void initState() {
    super.initState();
    _bleManager = BleManager();
    // Kick off a connection after first frame to avoid build-phase notifications
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bleManager.connect();
    });
  }

  @override
  void dispose() {
    _bleManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BleScope(
      manager: _bleManager,
      child: const CupertinoApp(
        title: 'F-stop Timer',
        theme: CupertinoThemeData(
          brightness: Brightness.dark,
          primaryColor: Color(0xFFFF0000), // bright red
          scaffoldBackgroundColor: Color(0xFF000000), // black background
          barBackgroundColor: Color(0xFF000000), // slightly lighter surface
          textTheme: CupertinoTextThemeData(
            textStyle: TextStyle(color: Color(0xFFCC0000)), // main red text
            primaryColor: Color(0xFFFF0000),
            actionTextStyle: TextStyle(color: Color(0xFF990000)), // muted red
            tabLabelTextStyle: TextStyle(color: Color(0xFF990000)),
          ),
        ),
        home: HomePage(),
      ),
    );
  }
}
