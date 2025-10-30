import 'package:flutter/material.dart';

import '../bluetooth/ble_scope.dart';

class TestStripPage extends StatelessWidget {
  const TestStripPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ble = BleScope.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: (!ble.connected && !ble.busy) ? () => ble.connect() : null,
                  child: Text(ble.busy ? "Connecting..." : "Connect"),
                ),
                const SizedBox(width: 12),
                Text(
                  ble.connected ? "Connected" : "Not connected",
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "BLE status: ${ble.bleStatus}",
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            if (ble.error != null)
              Text(ble.error!, style: const TextStyle(color: Colors.redAccent)),
            const SizedBox(height: 24),
            Text(
              "Test Strip",
              style: const TextStyle(fontSize: 24, color: Colors.white),
            ),
            const SizedBox(height: 12),
            const Text(
              "This is a placeholder page. Configure your test strip sequence here.",
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: (ble.connected && !ble.busy) ? () => ble.turnOn() : null,
                    child: const Text("Expose"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (ble.connected && !ble.busy) ? () => ble.turnOff() : null,
                    child: const Text("Stop"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: (ble.connected && !ble.busy) ? () => ble.toggle() : null,
              child: const Text("Toggle"),
            ),
          ],
        ),
      ),
    );
  }
}
