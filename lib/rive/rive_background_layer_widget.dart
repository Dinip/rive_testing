import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import 'rive_loaded_widget.dart';

class RiveBackgroundLayerWidget extends StatefulWidget {
  const RiveBackgroundLayerWidget({super.key});

  @override
  State<RiveBackgroundLayerWidget> createState() => _RiveBackgroundLayerWidgetState();
}

class _RiveBackgroundLayerWidgetState extends State<RiveBackgroundLayerWidget> {
  late final FileLoader fileLoader;

  @override
  void initState() {
    super.initState();
    fileLoader = FileLoader.fromAsset('packages/rive_testing/assets/example.riv', riveFactory: Factory.flutter);
  }

  @override
  void dispose() {
    fileLoader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RiveWidgetBuilder(
      fileLoader: fileLoader,
      builder: (context, state) => switch (state) {
        RiveLoaded s => RiveLoadedWidget(controller: s.controller, onReady: (controller) {}),
        _ => SizedBox.shrink(),
      },
    );
  }
}
