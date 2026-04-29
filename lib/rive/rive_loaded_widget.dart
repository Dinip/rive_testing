import 'package:flutter/widgets.dart';
import 'package:rive/rive.dart';

class RiveLoadedWidget extends StatefulWidget {
  const RiveLoadedWidget({super.key, required this.controller, required this.onReady, this.fit = Fit.none});

  final RiveWidgetController controller;
  final ValueChanged<RiveWidgetController> onReady;
  final Fit fit;

  @override
  State<RiveLoadedWidget> createState() => _RiveLoadedViewState();
}

class _RiveLoadedViewState extends State<RiveLoadedWidget> {
  @override
  void initState() {
    super.initState();
    widget.onReady(widget.controller);
  }

  @override
  Widget build(BuildContext context) {
    return RiveWidget(controller: widget.controller, fit: widget.fit, alignment: Alignment.topCenter);
  }
}
