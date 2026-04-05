import 'package:native_toolchain_ninja/native_toolchain_ninja.dart';
import 'package:code_assets/code_assets.dart';
import 'package:logging/logging.dart';
import 'package:hooks/hooks.dart';

import 'dart:ffi';

void main(List<String> args) async {
  await build(args, (input, output) async {
    final packageName = input.packageName;

    NinjaBuilder? ninjaBuilder;

    if (input.config.code.targetOS == OS.macOS) {
      ninjaBuilder = NinjaBuilder.library(
        name: packageName,
        assetName: 'macos',
        sources: ['src/macos.m'],
        language: Language.objectiveC,
        frameworks: ['AppKit'],
        flags: ['-O0', '-g3', "-fobjc-arc"],
      );
    }

    if (input.config.code.targetOS == OS.linux) {
      final abi = Abi.current();
      final libPrefix = abi == Abi.linuxArm64
          ? 'aarch64-linux-gnu'
          : 'x86_64-linux-gnu';
      ninjaBuilder = NinjaBuilder.library(
        name: packageName,
        assetName: 'linux',
        sources: [
          // 'src/linux/buffer.cpp',
          // 'src/linux/linux-dmabuf-unstable-v1-client-protocol.cpp',
          // 'src/linux/linux.cpp',
          // 'src/linux/wayland.cpp',
          // 'src/linux/window.cpp',
        ],
        buildMode: BuildMode.debug,
        optimizationLevel: OptimizationLevel.o0,
        flags: ['-g'],
        includes: [
          '/usr/include/gtk-3.0',
          '/usr/include/glib-2.0',
          '/usr/include/pango-1.0',
          '/usr/include/harfbuzz',
          '/usr/include/cairo',
          '/usr/include/gdk-pixbuf-2.0',
          '/usr/include/atk-1.0',
          '/usr/lib/$libPrefix/glib-2.0/include',
          '/usr/lib/$libPrefix/gtk-3.0/include',
        ],
        language: Language.cpp,
        libraries: ['gbm', 'EGL'],
      );
    }

    if (ninjaBuilder != null) {
      await ninjaBuilder.run(
        input: input,
        output: output,
        logger: Logger('')
          ..level = .ALL
          // ignore: avoid_print
          ..onRecord.listen((record) => print(record.message)),
      );
    }
  });
}
