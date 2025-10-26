import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

Future<void> ensureBlePermissions() async {
  if (Platform.isIOS) {
    final status = await Permission.bluetooth.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      throw Exception("Bluetooth permission not granted");
    }
  } else {
    throw Exception("BLE not implemented for this platform");
  }
}
