// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: implementation_imports

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/_window.dart';
import 'package:flutter/src/widgets/_window_macos.dart';

import 'src/macos.g.dart';

import 'dart:ffi' hide Size;

import 'src/widgets.dart';

class MainControllerWindowDelegate with RegularWindowControllerDelegate {
  @override
  void onWindowDestroyed() {
    super.onWindowDestroyed();
    exit(0);
  }
}

void main() {
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
                  SizedBox(width: 40,),
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

class _MultiWindowAppState extends State<MultiWindowApp> {
  final RegularWindowController controller = RegularWindowController(
    preferredSize: const Size(800, 600),
    title: 'Multi-Window Reference Application',
    delegate: MainControllerWindowDelegate(),
  );

  @override
  void initState() {
    if (controller is WindowControllerMacOS) {
      final controllerMacOS = controller as WindowControllerMacOS;
      cw_nswindow_remove_titlebar(controllerMacOS.getWindowHandle());
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
