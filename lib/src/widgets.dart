// ignore_for_file: implementation_imports, invalid_use_of_internal_member

import 'package:flutter/widgets.dart';
import 'package:headless_widgets/headless_widgets.dart';
import 'custom_window.dart';

import 'package:flutter/src/widgets/_window.dart';

class WindowDraggableArea extends StatefulWidget {
  const WindowDraggableArea({super.key, required this.child});

  final Widget child;

  @override
  State<WindowDraggableArea> createState() => _WindowDraggableAreaState();
}

class WindowDraggableExclude extends StatefulWidget {
  const WindowDraggableExclude({super.key, required this.child});

  final Widget child;

  @override
  State<WindowDraggableExclude> createState() => _WindowDragExcludeState();
}

class WindowTrafficLight extends StatefulWidget {
  const WindowTrafficLight({super.key});

  @override
  State<WindowTrafficLight> createState() => _WindowTrafficLightState();
}

class TitlebarButtonState {
  TitlebarButtonState({
    required this.enabled,
    required this.hovered,
    required this.pressed,
  });

  final bool enabled;
  final bool hovered;
  final bool pressed;
}

class MaximizeButton extends StatefulWidget {
  const MaximizeButton({super.key, required this.builder, this.enabled = true});

  final Widget Function(
    BuildContext context,
    TitlebarButtonState state,
    bool isMaximized,
  )
  builder;

  final bool enabled;

  @override
  State<MaximizeButton> createState() => _MaximizeButtonState();
}

class MinimizeButton extends StatefulWidget {
  const MinimizeButton({super.key, required this.builder, this.enabled = true});

  final Widget Function(BuildContext context, TitlebarButtonState state)
  builder;

  final bool enabled;

  @override
  State<MinimizeButton> createState() => _MinimizeButtonState();
}

class CloseButton extends StatefulWidget {
  const CloseButton({super.key, required this.builder, this.enabled = true});

  final Widget Function(BuildContext context, TitlebarButtonState state)
  builder;

  final bool enabled;

  @override
  State<CloseButton> createState() => _CloseButtonState();
}

class _CloseButtonState extends State<CloseButton> {
  @override
  Widget build(BuildContext context) {
    return WindowDraggableExclude(
      child: Button(
        builder: (context, buttonState, child) {
          return widget.builder(
            context,
            TitlebarButtonState(
              enabled: buttonState.enabled,
              hovered: buttonState.hovered,
              pressed: buttonState.pressed,
            ),
          );
        },
        focusNode: _buttonNode,
        onPressed: widget.enabled ? _onPressed : null,
      ),
    );
  }

  void _onPressed() {
    final customWindow = CustomWindow.forController(WindowScope.of(context));
    customWindow?.requestClose();
  }

  final _buttonNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _buttonNode.canRequestFocus = false;
    _buttonNode.skipTraversal = true;
  }

  @override
  void dispose() {
    super.dispose();
    _buttonNode.dispose();
  }
}

class _MinimizeButtonState extends State<MinimizeButton> {
  @override
  Widget build(BuildContext context) {
    return WindowDraggableExclude(
      child: Button(
        builder: (context, buttonState, child) {
          return widget.builder(
            context,
            TitlebarButtonState(
              enabled: buttonState.enabled,
              hovered: buttonState.hovered,
              pressed: buttonState.pressed,
            ),
          );
        },
        focusNode: _buttonNode,
        onPressed: widget.enabled ? _onPressed : null,
      ),
    );
  }

  void _onPressed() {
    final controller = WindowScope.of(context);
    if (controller is RegularWindowController) {
      controller.setMinimized(true);
    } else if (controller is DialogWindowController) {
      controller.setMinimized(true);
    }
  }

  final _buttonNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _buttonNode.canRequestFocus = false;
    _buttonNode.skipTraversal = true;
  }

  @override
  void dispose() {
    super.dispose();
    _buttonNode.dispose();
  }
}

class _MaximizeButtonState extends _FrameReportingState<MaximizeButton> {
  @override
  Widget build(BuildContext context) {
    return Button(
      builder: (context, buttonState, child) {
        return widget.builder(
          context,
          TitlebarButtonState(
            enabled: buttonState.enabled,
            hovered: buttonState.hovered,
            pressed: buttonState.pressed,
          ),
          _isMaximized,
        );
      },
      focusNode: _buttonNode,
      onPressed: widget.enabled ? _onPressed : null,
    );
  }

  void _onPressed() {
    final controller = WindowScope.of(context) as RegularWindowController;
    controller.setMaximized(!controller.isMaximized);
  }

  BaseWindowController? _controller;
  bool _lastMaximized = false;
  final _buttonNode = FocusNode();
  bool get _isMaximized => (_controller as RegularWindowController).isMaximized;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller?.removeListener(_controllerListener);
    _controller = WindowScope.of(context);
    _controller!.addListener(_controllerListener);
  }

  void _controllerListener() {
    if (!mounted) {
      return;
    }
    if (_isMaximized != _lastMaximized) {
      _lastMaximized = _isMaximized;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _buttonNode.canRequestFocus = false;
    _buttonNode.skipTraversal = true;
  }

  @override
  void dispose() {
    super.dispose();
    _buttonNode.dispose();
    _controller?.removeListener(_controllerListener);
  }

  @override
  void reportFrame(CustomWindow window, Rect? rect) {
    window.setMaximizeButtonFrame(context, rect);
  }
}

abstract class _FrameReportingState<T extends StatefulWidget> extends State<T> {
  void reportFrame(CustomWindow window, Rect? rect);

  CustomWindow? _customWindow;

  void _frameTick() {
    if (!mounted) {
      return;
    }

    final customWindow = CustomWindow.forController(WindowScope.of(context));
    if (customWindow != null) {
      final view = context.findRenderObject() as RenderBox;
      final transform = view.getTransformTo(null);
      final rect = MatrixUtils.transformRect(
        transform,
        Offset.zero & view.size,
      );
      if (_customWindow != customWindow) {
        if (_customWindow != null) {
          reportFrame(customWindow, null);
        }
        _customWindow = customWindow;
      }
      reportFrame(customWindow, rect);
    }
  }

  @override
  void initState() {
    super.initState();
    _PersistentFrameCallbackManager.instance.addCallback(_frameTick);
  }

  @override
  void dispose() {
    _PersistentFrameCallbackManager.instance.removeCallback(_frameTick);
    if (_customWindow != null) {
      reportFrame(_customWindow!, null);
    }
    super.dispose();
  }
}

class _WindowDraggableAreaState
    extends _FrameReportingState<WindowDraggableArea> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void reportFrame(CustomWindow window, Rect? rect) {
    window.setDraggableRectForElement(context, rect);
  }
}

class _WindowDragExcludeState
    extends _FrameReportingState<WindowDraggableExclude> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void reportFrame(CustomWindow window, Rect? rect) {
    window.setDragExcludeRectForElement(context, rect);
  }
}

class _WindowTrafficLightState
    extends _FrameReportingState<WindowTrafficLight> {
  @override
  Widget build(BuildContext context) {
    final customWindow = CustomWindow.forController(WindowScope.of(context));
    if (customWindow == null) {
      return const SizedBox.shrink();
    } else {
      return SizedBox.fromSize(size: customWindow.getTrafficLightSize());
    }
  }

  @override
  void reportFrame(CustomWindow window, Rect? rect) {
    if (rect != null) {
      window.setTrafficLightPosition(rect.topLeft);
    }
  }
}

class _PersistentFrameCallbackManager {
  _PersistentFrameCallbackManager._() {
    WidgetsBinding.instance.addPersistentFrameCallback((_) {
      final callbacksCopy = List<VoidCallback>.from(
        _callbacks,
        growable: false,
      );
      for (final callback in callbacksCopy) {
        callback();
      }
    });
  }

  void addCallback(VoidCallback callback) {
    _callbacks.add(callback);
  }

  void removeCallback(VoidCallback callback) {
    _callbacks.remove(callback);
  }

  final _callbacks = <VoidCallback>[];
  static final instance = _PersistentFrameCallbackManager._();
}
