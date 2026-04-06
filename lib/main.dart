// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: implementation_imports

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:custom_window/src/custom_window.dart';
import 'package:flutter/material.dart' hide CloseButton;
import 'package:flutter/src/widgets/_window.dart';

import 'src/widgets.dart';

class MainControllerWindowDelegate with RegularWindowControllerDelegate {
  @override
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
    return Container(
      decoration: BoxDecoration(
        // border: Border.all(color: Colors.blue, width: 1),
        color: Colors.black,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          WindowDraggableArea(
            child: GestureDetector(
              // onDoubleTap: () {
              //   final controller = WindowScope.of(context);
              //   final regular = controller as RegularWindowController;
              //   regular.setMaximized(!regular.isMaximized);
              // },
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
                    MinimizeButton(
                      builder: (context, state) {
                        Color color;
                        if (state.pressed) {
                          color = Colors.red;
                        } else if (state.hovered) {
                          color = Colors.green;
                        } else {
                          color = Colors.blue;
                        }
                        return Container(width: 40, color: color);
                      },
                    ),
                    MaximizeButton(
                      builder: (context, state, isMaximized) {
                        Color color;
                        if (state.pressed) {
                          color = Colors.red;
                        } else if (state.hovered) {
                          color = Colors.green;
                        } else {
                          color = Colors.blue;
                        }
                        return Container(width: 40, color: color);
                      },
                    ),
                    CloseButton(
                      builder: (context, state) {
                        Color color;
                        if (state.pressed) {
                          color = Colors.red;
                        } else if (state.hovered) {
                          color = Colors.green;
                        } else {
                          color = Colors.blue;
                        }
                        return Container(width: 40, color: color);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 50),
          WindowDraggableArea(
            child: Container(color: Colors.green, height: 30),
          ),
          Expanded(child: Text('Hello')),
        ],
      ),
    );
  }
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
    CustomWindow.init(controller);
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
