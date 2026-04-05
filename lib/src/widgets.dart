// ignore_for_file: implementation_imports, invalid_use_of_internal_member

import 'package:flutter/widgets.dart';
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

class _WindowDraggableAreaState extends State<WindowDraggableArea> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

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
        _customWindow?.setDraggableRectForElement(context, null);
        _customWindow = customWindow;
      }
      customWindow.setDraggableRectForElement(context, rect);
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
    _customWindow?.setDraggableRectForElement(context, null);
    super.dispose();
  }
}

class _WindowDragExcludeState extends State<WindowDraggableExclude> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

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
        _customWindow?.setDragExcludeRectForElement(context, null);
        _customWindow = customWindow;
      }
      customWindow.setDragExcludeRectForElement(context, rect);
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
    _customWindow?.setDragExcludeRectForElement(context, null);
    super.dispose();
  }
}

class _WindowTrafficLightState extends State<WindowTrafficLight> {
  @override
  Widget build(BuildContext context) {
    final customWindow = CustomWindow.forController(WindowScope.of(context));
    if (customWindow == null) {
      return const SizedBox.shrink();
    } else {
      return SizedBox.fromSize(size: customWindow.getTrafficLightSize());
    }
  }

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
      customWindow.setTrafficLightPosition(rect.topLeft);
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
    super.dispose();
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
