import 'dart:async';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'ble_ids.dart';

class FStopBleService {
  final FlutterReactiveBle _ble = FlutterReactiveBle();

  FStopBleService() {
    _ble.statusStream.listen((status) {
      print("BLE status: $status");
      // You can react here if you want to handle specific states:
      // if (status == BleStatus.unauthorized) { ... }
    });
  }

  DiscoveredDevice? _device;
  StreamSubscription<DiscoveredDevice>? _scanSub;
  StreamSubscription<ConnectionStateUpdate>? _connSub;

  QualifiedCharacteristic? _cmdChar;
  QualifiedCharacteristic? _statusChar;

  // Emits true for ON, false for OFF
  final StreamController<bool> _relayStateCtl = StreamController.broadcast();
  Stream<bool> get relayStateStream => _relayStateCtl.stream;

  Future<String> scanAndConnect({Duration timeout = const Duration(seconds: 8)}) async {
    final completer = Completer<String>();
    _scanSub = _ble.scanForDevices(withServices: [serviceUuid]).listen((d) {
      print(d);
      if (d.name == deviceNameHint || d.serviceUuids.contains(serviceUuid)) {
        _device = d;
        _scanSub?.cancel();
        _connect(d.id).then((_) => completer.complete(d.id)).catchError(completer.completeError);
      }
    }, onError: completer.completeError);

    // Safety timeout
    Future.delayed(timeout, () {
      if (!completer.isCompleted) {
        _scanSub?.cancel();
        completer.completeError("Scan timeout: device not found");
      }
    });

    return completer.future;
  }

  Future<void> _connect(String id) async {
    _connSub = _ble.connectToDevice(id: id).listen((update) async {
      if (update.connectionState == DeviceConnectionState.connected) {
        _cmdChar = QualifiedCharacteristic(deviceId: id, serviceId: serviceUuid, characteristicId: cmdUuid);
        _statusChar = QualifiedCharacteristic(deviceId: id, serviceId: serviceUuid, characteristicId: statusUuid);

        // Read initial state once
        try {
          final initial = await _ble.readCharacteristic(_statusChar!);
          _emitStatus(initial);
        } catch (_) {}

        // Subscribe to ongoing changes
        _ble.subscribeToCharacteristic(_statusChar!).listen(_emitStatus, onError: (_) {});
      }
    }, onError: (e) {
      // pass
    });
  }

  void _emitStatus(List<int> payload) {
    final text = String.fromCharCodes(payload).trim().toUpperCase();
    _relayStateCtl.add(text == "ON");
  }

  Future<void> turnOn() async {
    if (_cmdChar == null) throw Exception("Not connected");
    await _ble.writeCharacteristicWithoutResponse(_cmdChar!, value: "ON".codeUnits);
  }

  Future<void> turnOff() async {
    if (_cmdChar == null) throw Exception("Not connected");
    await _ble.writeCharacteristicWithoutResponse(_cmdChar!, value: "OFF".codeUnits);
  }

  Future<void> toggle() async {
    if (_cmdChar == null) throw Exception("Not connected");
    await _ble.writeCharacteristicWithoutResponse(_cmdChar!, value: "TOGGLE".codeUnits);
  }

  Future<void> disconnect() async {
    await _scanSub?.cancel();
    await _connSub?.cancel();
  }

  void dispose() {
    _relayStateCtl.close();
  }
}
