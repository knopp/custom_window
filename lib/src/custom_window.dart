// ignore_for_file: invalid_use_of_internal_member
// ignore: implementation_imports
import 'package:flutter/src/widgets/_window.dart';
import 'package:flutter/widgets.dart';

abstract class CustomWindow {
  static CustomWindow forController(BaseWindowController controller) {
    throw UnimplementedError();
  }

  void setDraggableRectForElement(Element element, Rect? rect);
  void setDragExcludeRectForElement(Element element, Rect? rect);
  void setTrafficLightPosition(Offset offset);
  Size getTrafficLightSize();
  void setWindowBorderSize(double size);
}
