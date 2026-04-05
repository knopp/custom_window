// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: implementation_imports

import 'dart:convert';
import 'dart:developer';
import 'dart:ffi' hide Size;
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/_window.dart';
import 'package:flutter/src/widgets/_window_macos.dart';
import 'package:flutter/src/widgets/_window_win32.dart';

import 'src/macos.g.dart';
import 'src/windows.g.dart';

import 'src/widgets.dart';

import 'package:win32/win32.dart' hide HWND;
import 'package:win32/win32.dart' as win32 show HWND;

class MainControllerWindowDelegate with RegularWindowControllerDelegate {
  @override
  void onWindowDestroyed() {
    super.onWindowDestroyed();
    exit(0);
  }
}

void main() async {
  final info = await Service.getInfo();
  if (info.serverUri != null) {
    final json = {'uri': info.serverUri.toString()};
    File('vmservice.json').writeAsStringSync(jsonEncode(json));
  }
  WidgetsFlutterBinding.ensureInitialized();

  runWidget(MultiWindowApp());
}

class MultiWindowApp extends StatefulWidget {
  const MultiWindowApp({super.key});

  @override
  State<MultiWindowApp> createState() => _MultiWindowAppState();
}

class MainWindow extends StatelessWidget {
  final RegularWindowController controller;

  const MainWindow({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        WindowDraggableArea(
          child: GestureDetector(
            onDoubleTap: () {
              final controller = WindowScope.of(context);
              final regular = controller as RegularWindowController;
              regular.setMaximized(!regular.isMaximized);
            },
            child: Container(
              color: const Color.fromARGB(255, 6, 78, 8),
              height: 40,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(width: 40),
                  Center(child: WindowTrafficLight()),
                  Spacer(),
                  WindowDraggableExclude(
                    child: Container(width: 40, color: Colors.red),
                  ),
                  Spacer(),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 50),
        WindowDraggableArea(child: Container(color: Colors.green, height: 30)),
        Expanded(child: Text('Hello')),
      ],
    );
  }
}

// const WM_NCCALCSIZE = 0x0083;
// const WM_NCHITTEST = 0x0084;

// const HTCLIENT = 1;
// const HTCAPTION = 2;
// const HTLEFT = 10;
// const HTRIGHT = 11;
// const HTTOP = 12;
// const HTTOPLEFT = 13;
// const HTTOPRIGHT = 14;
// const HTBOTTOM = 15;
// const HTBOTTOMLEFT = 16;
// const HTBOTTOMRIGHT = 17;
// const HTNOWHERE = 0;
// const HTZOOM = 20;
// const HTMAXBUTTON = 9;
// const HTMINBUTTON = 8;
// const HTREDUCE = 8;
// const HTMENU = 5;

//  UINT FlutterDesktopGetDpiForHWND(HWND hwnd);
int GetDpiForHWND(Pointer<Void> hwnd) {
  final dylib = DynamicLibrary.process();
  final func = dylib
      .lookupFunction<
        Uint32 Function(Pointer<Void>),
        int Function(Pointer<Void>)
      >('FlutterDesktopGetDpiForHWND');
  return func(hwnd);
}

class MessageHandler implements WindowsMessageHandler {
  @override
  int? handleWindowsMessage(
    HWND windowHandle,
    int message,
    int wParam,
    int lParam,
  ) {
    if (message == WM_NCCALCSIZE) {
      if (wParam == 1) {
        return 0;
      }
    } else if (message == WM_NCHITTEST) {
      final xPos = lParam & 0xFFFF;
      final yPos = (lParam >> 16) & 0xFFFF;

      final point = malloc<POINT>();
      point.ref.x = xPos;
      point.ref.y = yPos;
      ScreenToClient(win32.HWND(windowHandle), point);

      int dpi = GetDpiForHWND(windowHandle);
      double scale = dpi / 96.0;
      double x = point.ref.x / scale;
      double y = point.ref.y / scale;

      malloc.free(point);

      final rect = malloc<RECT>();
      GetClientRect(win32.HWND(windowHandle), rect);
      final width = (rect.ref.right - rect.ref.left) / scale;
      final height = (rect.ref.bottom - rect.ref.top) / scale;
      malloc.free(rect);

      const edgeSize = 10;
      if (y < edgeSize) {
        if (x < edgeSize) {
          return HTTOPLEFT;
        } else if (x > width - edgeSize) {
          return HTTOPRIGHT;
        } else {
          return HTTOP;
        }
      } else if (y > height - edgeSize) {
        if (x < edgeSize) {
          return HTBOTTOMLEFT;
        } else if (x > width - edgeSize) {
          return HTBOTTOMRIGHT;
        } else {
          return HTBOTTOM;
        }
      } else if (x < edgeSize) {
        return HTLEFT;
      } else if (x > width - edgeSize) {
        return HTRIGHT;
      }

      return HTCAPTION;
    }
    return null;
  }
}

void makeWindowUndecorated(win32.HWND hwnd) {
  SetWindowLongPtr(
    hwnd,
    GWL_STYLE,
    WS_THICKFRAME |
        WS_CAPTION |
        WS_MAXIMIZEBOX |
        WS_MINIMIZEBOX |
        WS_OVERLAPPED,
  );
  SetWindowPos(
    hwnd,
    null,
    0,
    0,
    0,
    0,
    SWP_FRAMECHANGED | SWP_NOMOVE | SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE,
  );

  final margins = malloc<MARGINS>();
  margins.ref.cxLeftWidth = 0;
  margins.ref.cxRightWidth = 0;
  margins.ref.cyTopHeight = 1;
  margins.ref.cyBottomHeight = 0;
  DwmExtendFrameIntoClientArea(hwnd, margins);
  malloc.free(margins);
}

class _MultiWindowAppState extends State<MultiWindowApp> {
  late final RegularWindowController controller;

  @override
  void initState() {
    controller = RegularWindowController(
      preferredSize: const Size(800, 600),
      title: 'Multi-Window Reference Application',
      delegate: MainControllerWindowDelegate(),
    );
    if (controller is WindowControllerMacOS) {
      final controllerMacOS = controller as WindowControllerMacOS;
      cw_nswindow_remove_titlebar(controllerMacOS.getWindowHandle());
    } else if (controller is WindowControllerWin32) {
      final controllerWin32 = controller as WindowControllerWin32;
      controllerWin32.addWindowsMessageHandler(MessageHandler());
      makeWindowUndecorated(win32.HWND(controllerWin32.getWindowHandle()));
    }
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RegularWindow(
      controller: controller,
      child: MaterialApp(home: MainWindow(controller: controller)),
    );
  }
}
