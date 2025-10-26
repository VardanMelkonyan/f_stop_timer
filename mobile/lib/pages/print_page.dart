import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import '../bluetooth/ble_premissions.dart';
import '../bluetooth/ble_service.dart';

class PrintPage extends StatefulWidget {
  const PrintPage({super.key});
  @override
  State<PrintPage> createState() => _PrintPageState();
}

class _PrintPageState extends State<PrintPage>
    with SingleTickerProviderStateMixin {

  final FStopBleService _ble = FStopBleService();
  bool _connected = false;
  bool _isOn = false;
  String? _error;

  @override
  void dispose() {
    _ble.disconnect();
    _ble.dispose();
    super.dispose();
  }


  @override
  void initState() {
    super.initState();
    // Listen for global BLE status changes
    final reactiveBle = FlutterReactiveBle();
    reactiveBle.statusStream.listen((status) {
      print("BLE status: $status");
      // show snackbar, dialog, etc. if unauthorized or poweredOff
    });
  }


  Future<void> _connect() async {
    setState(() => _error = null);
    try {
      await ensureBlePermissions();
      final id = await _ble.scanAndConnect();
      setState(() => _connected = true);
      _ble.relayStateStream.listen((v) => setState(() => _isOn = v));
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: _connected ? null : _connect,
                  child: const Text("Connect"),
                ),
                const SizedBox(width: 12),
                Text(
                  _connected ? "Connected" : "Not connected",
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.redAccent)),
            const SizedBox(height: 24),
            Text(
              "Relay: ${_isOn ? "ON" : "OFF"}",
              style: const TextStyle(fontSize: 24, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _connected ? () => _ble.turnOn() : null,
                    child: const Text("Turn ON"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _connected ? () => _ble.turnOff() : null,
                    child: const Text("Turn OFF"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _connected ? () => _ble.toggle() : null,
              child: const Text("Toggle"),
            ),
          ],
        ),
      ),
    );
  }
}
