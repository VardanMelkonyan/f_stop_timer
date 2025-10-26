import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

// Replace with YOUR values (must match ESP32 firmware)
final serviceUuid  = Uuid.parse("FA71809B-52E8-4DF2-BCE1-9C4D42311C97");
final cmdUuid      = Uuid.parse("E8C858FA-E034-4EBF-A8C6-397401281056");
final statusUuid   = Uuid.parse("58707319-E7C8-40BA-8A05-A3AE010B4997");

// Your ESP32 advertised name (optional optimization)
const deviceNameHint = "FStopTimer";
