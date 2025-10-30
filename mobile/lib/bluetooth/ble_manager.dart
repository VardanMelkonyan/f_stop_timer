import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import 'ble_premissions.dart';
import 'ble_service.dart';

/// High-level application state for BLE.
///
/// This wraps the low-level FStopBleService (which talks to the device)
/// and exposes a simple, app-wide state and commands that widgets can use.
class BleManager extends ChangeNotifier {
  final FStopBleService _service;
  final FlutterReactiveBle _reactiveBle = FlutterReactiveBle();

  BleManager({FStopBleService? service}) : _service = service ?? FStopBleService() {
    // Listen to platform BLE status once at the manager level
    _statusSub = _reactiveBle.statusStream.listen((s) {
      _bleStatus = s;
      notifyListeners();
    });
  }

  // State
  bool _connected = false;
  bool get connected => _connected;

  bool _isOn = false;
  bool get isOn => _isOn;

  bool _busy = false;
  bool get busy => _busy;

  String? _error;
  String? get error => _error;

  BleStatus _bleStatus = BleStatus.unknown;
  BleStatus get bleStatus => _bleStatus;

  // Subscriptions
  StreamSubscription<bool>? _relaySub;
  StreamSubscription<BleStatus>? _statusSub;

  Future<void> connect() async {
    if (_connected || _busy) return;
    _setBusy(true);
    _setError(null);
    try {
      await ensureBlePermissions();
      await _service.scanAndConnect();
      _connected = true;
      // Listen for relay state updates
      _relaySub?.cancel();
      _relaySub = _service.relayStateStream.listen((v) {
        _isOn = v;
        notifyListeners();
      });
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setBusy(false);
    }
  }

  Future<void> disconnect() async {
    await _service.disconnect();
    _connected = false;
    _relaySub?.cancel();
    _relaySub = null;
    notifyListeners();
  }

  Future<void> turnOn() async {
    await _guarded(() => _service.turnOn());
  }

  Future<void> turnOff() async {
    await _guarded(() => _service.turnOff());
  }

  Future<void> toggle() async {
    await _guarded(() => _service.toggle());
  }

  Future<void> _guarded(Future<void> Function() op) async {
    if (!_connected) {
      _setError('Not connected');
      return;
    }
    _setBusy(true);
    _setError(null);
    try {
      await op();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setBusy(false);
    }
  }

  void _setBusy(bool v) {
    if (_busy == v) return;
    _busy = v;
    notifyListeners();
  }

  void _setError(String? msg) {
    _error = msg;
    notifyListeners();
  }

  @override
  void dispose() {
    _relaySub?.cancel();
    _statusSub?.cancel();
    _service.dispose();
    super.dispose();
  }
}
