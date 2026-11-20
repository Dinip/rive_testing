import 'package:flutter/material.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:rive_testing/rive/rive_background_layer_widget.dart';

void main() {
  testGoldens('theme background should be visible with default color', (tester) async {
    await tester.pumpWidgetBuilder(
      MaterialApp(debugShowCheckedModeBanner: false, home: Scaffold(body: RiveBackgroundLayerWidget())),
      wrapper: noWrap(),
      surfaceSize: Size(500, 500),
    );
    await screenMatchesGolden(tester, 'golden', customPump: (t) => t.pump(Durations.extralong4));
  });
}
