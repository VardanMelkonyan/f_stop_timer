import 'package:flutter/widgets.dart';

import 'ble_manager.dart';

/// Simple app-scoped provider for [BleManager] without external packages.
class BleScope extends InheritedNotifier<BleManager> {
  const BleScope({super.key, required BleManager manager, required Widget child})
      : super(notifier: manager, child: child);

  static BleManager of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<BleScope>();
    assert(scope != null, 'BleScope.of() called with a context that has no BleScope in the tree.');
    return scope!.notifier!;
  }
}
