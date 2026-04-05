// ignore_for_file: implementation_imports, invalid_use_of_internal_member

import 'package:flutter/src/widgets/_window.dart';
import 'package:flutter/src/widgets/_window_macos.dart';
import 'package:flutter/widgets.dart';

import 'custom_window_macos.dart';

abstract class CustomWindow {
  static CustomWindow? forController(BaseWindowController controller) {
    return _expando[controller];
  }

  static void init(BaseWindowController controller) {
    final created = _create(controller);
    if (created != null) {
      _expando[controller] = created;
    }
  }

  static final _expando = Expando<CustomWindow>('CustomWindow');

  static CustomWindow? _create(BaseWindowController controller) {
    if (controller is WindowControllerMacOS) {
      return CustomWindowMacOS(controller as WindowControllerMacOS);
    } else {
      return null;
    }
  }

  void setDraggableRectForElement(BuildContext element, Rect? rect);
  void setDragExcludeRectForElement(BuildContext element, Rect? rect);
  void setTrafficLightPosition(Offset offset);
  Size getTrafficLightSize();
  void setWindowBorderSize(double size);
}
