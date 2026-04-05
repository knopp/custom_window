// ignore_for_file: invalid_use_of_internal_member

import 'dart:async';

import 'package:custom_window/src/invert_rectanges.dart';
import 'package:custom_window/src/macos.g.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'dart:ffi' hide Size;
import 'package:ffi/ffi.dart' as ffi;

import 'package:flutter/src/widgets/_window.dart';
import 'package:flutter/src/widgets/_window_macos.dart';

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

  void _frameTick() {
    if (!mounted) {
      return;
    }
    final controller = WindowScope.maybeOf(context);
    if (controller != null) {
      _DraggableState.forController(
        controller,
      )._draggableElements.add(context as Element);
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

class _WindowDragExcludeState extends State<WindowDraggableExclude> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void _frameTick() {
    if (!mounted) {
      return;
    }
    final controller = WindowScope.maybeOf(context);
    if (controller != null) {
      _DraggableState.forController(
        controller,
      )._preventionElements.add(context as Element);
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

class _WindowTrafficLightState extends State<WindowTrafficLight> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 54, height: 16);
  }

  void _frameTick() {
    if (!mounted) {
      return;
    }
    final controller = WindowScope.maybeOf(context);
    if (controller is WindowControllerMacOS) {
      final controllerMacOS = controller as WindowControllerMacOS;
      final view = context.findRenderObject() as RenderBox;
      final transform = view.getTransformTo(null);
      final rect = MatrixUtils.transformRect(
        transform,
        Offset.zero & view.size,
      );
      cw_nswindow_update_traffic_light(
        controllerMacOS.getWindowHandle(),
        true,
        rect.left,
        rect.top,
      );
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

class _DraggableState {
  static _DraggableState forController(BaseWindowController controller) {
    return _scheduled.putIfAbsent(controller, () {
      scheduleMicrotask(() {
        final state = _scheduled.remove(controller)!;
        state._submit(controller);
      });
      return _DraggableState();
    });
  }

  void _submit(BaseWindowController controller) {
    _draggableElements.removeWhere((e) => !e.mounted);
    _preventionElements.removeWhere((e) => !e.mounted);
    if (_draggableElements.isEmpty) {
      if (controller is WindowControllerMacOS) {
        final controllerMacOS = controller as WindowControllerMacOS;
        cw_nswindow_disable_draggable_areas(controllerMacOS.getWindowHandle());
      }
    } else {
      final view = _draggableElements.first
          .findAncestorRenderObjectOfType<RenderView>();
      if (view == null) {
        throw StateError('Unexpectedly missing RenderView in heirarchy');
      }
      final bounds = Offset.zero & view.size;
      final draggableRects = <Rect>[];
      final preventionRects = <Rect>[];

      void addElementRect(List<Rect> where, Element element) {
        final renderBox = element.findRenderObject()! as RenderBox;
        final transform = renderBox.getTransformTo(null);
        final rect = MatrixUtils.transformRect(
          transform,
          Offset.zero & renderBox.size,
        );
        where.add(rect);
      }

      for (final element in _draggableElements) {
        addElementRect(draggableRects, element);
      }

      for (final element in _preventionElements) {
        addElementRect(preventionRects, element);
      }

      final draggableInverted = invert(bounds, draggableRects);

      final count = draggableInverted.length + preventionRects.length;

      final rectsPointer = ffi.malloc<cw_rect_t>(count);

      for (final (index, rect)
          in draggableInverted.followedBy(preventionRects).indexed) {
        rectsPointer[index].x = rect.left;
        rectsPointer[index].y = rect.top;
        rectsPointer[index].w = rect.width;
        rectsPointer[index].h = rect.height;
      }

      if (controller is WindowControllerMacOS) {
        final controllerMacOS = controller as WindowControllerMacOS;
        cw_nswindow_update_draggable_areas(
          controllerMacOS.getWindowHandle(),
          rectsPointer,
          count,
        );
      }
    }
  }

  final _draggableElements = <Element>[];
  final _preventionElements = <Element>[];

  static final _scheduled = <BaseWindowController, _DraggableState>{};
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
