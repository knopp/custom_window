import 'dart:ui';

import 'package:custom_window/src/invert_rectanges.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('invert', () {
    test('returns bounds when nothing is excluded', () {
      expect(
        invert(const Rect.fromLTWH(0, 0, 100, 80), const <Rect>[]),
        const <Rect>[Rect.fromLTWH(0, 0, 100, 80)],
      );
    });

    test('ignores exclusions that do not intersect the bounds', () {
      expect(
        invert(const Rect.fromLTWH(0, 0, 100, 80), const <Rect>[
          Rect.fromLTWH(150, 10, 30, 20),
        ]),
        const <Rect>[Rect.fromLTWH(0, 0, 100, 80)],
      );
    });

    test('clips a partially overlapping exclusion to the bounds', () {
      expect(
        invert(const Rect.fromLTWH(0, 0, 100, 100), const <Rect>[
          Rect.fromLTWH(-20, -10, 50, 40),
        ]),
        const <Rect>[
          Rect.fromLTRB(30, 0, 100, 30),
          Rect.fromLTRB(0, 30, 100, 100),
        ],
      );
    });

    test('returns an empty list when the exclusion covers the bounds', () {
      expect(
        invert(const Rect.fromLTWH(0, 0, 100, 80), const <Rect>[
          Rect.fromLTWH(-10, -10, 200, 200),
        ]),
        isEmpty,
      );
    });

    test('creates four surrounding rectangles for a centered hole', () {
      expect(
        invert(const Rect.fromLTWH(0, 0, 100, 100), const <Rect>[
          Rect.fromLTWH(25, 25, 50, 50),
        ]),
        const <Rect>[
          Rect.fromLTRB(0, 0, 100, 25),
          Rect.fromLTRB(0, 25, 25, 75),
          Rect.fromLTRB(75, 25, 100, 75),
          Rect.fromLTRB(0, 75, 100, 100),
        ],
      );
    });

    test('handles multiple separated exclusions', () {
      expect(
        invert(const Rect.fromLTWH(0, 0, 120, 80), const <Rect>[
          Rect.fromLTWH(10, 10, 20, 20),
          Rect.fromLTWH(70, 30, 30, 20),
        ]),
        const <Rect>[
          Rect.fromLTRB(0, 0, 120, 10),
          Rect.fromLTRB(0, 10, 10, 30),
          Rect.fromLTRB(30, 10, 120, 30),
          Rect.fromLTRB(0, 30, 70, 50),
          Rect.fromLTRB(100, 30, 120, 50),
          Rect.fromLTRB(0, 50, 120, 80),
        ],
      );
    });

    test('complex shape', () {
      expect(
        invert(Rect.fromLTWH(0, 0, 100, 100), [
          Rect.fromLTRB(10, 10, 40, 40),
          Rect.fromLTRB(60, 10, 90, 40),
          Rect.fromLTRB(30, 30, 70, 60),
          Rect.fromLTRB(10, 70, 40, 90),
          Rect.fromLTRB(50, 70, 90, 75),
          Rect.fromLTRB(50, 80, 90, 85),
          Rect.fromLTRB(50, 90, 90, 95),
          Rect.fromLTRB(70, 73, 75, 80),
        ]),
        [
          Rect.fromLTRB(0.0, 0.0, 100.0, 10.0),
          Rect.fromLTRB(0.0, 10.0, 10.0, 30.0),
          Rect.fromLTRB(40.0, 10.0, 60.0, 30.0),
          Rect.fromLTRB(90.0, 10.0, 100.0, 30.0),
          Rect.fromLTRB(0, 30, 10, 40),
          Rect.fromLTRB(90.0, 30.0, 100.0, 40.0),
          Rect.fromLTRB(0.0, 40.0, 30.0, 60.0),
          Rect.fromLTRB(70.0, 40.0, 100.0, 60.0),
          Rect.fromLTRB(0.0, 60.0, 100.0, 70.0),
          Rect.fromLTRB(0.0, 70.0, 10.0, 73.0),
          Rect.fromLTRB(40.0, 70.0, 50.0, 73.0),
          Rect.fromLTRB(90.0, 70.0, 100.0, 73.0),
          Rect.fromLTRB(0.0, 73.0, 10.0, 75.0),
          Rect.fromLTRB(40.0, 73.0, 50.0, 75.0),
          Rect.fromLTRB(90.0, 73.0, 100.0, 75.0),
          Rect.fromLTRB(0.0, 75.0, 10.0, 80.0),
          Rect.fromLTRB(40.0, 75.0, 70.0, 80.0),
          Rect.fromLTRB(75.0, 75.0, 100.0, 80.0),
          Rect.fromLTRB(0.0, 80.0, 10.0, 85.0),
          Rect.fromLTRB(40.0, 80.0, 50.0, 85.0),
          Rect.fromLTRB(90.0, 80.0, 100.0, 85.0),
          Rect.fromLTRB(0.0, 85.0, 10.0, 90.0),
          Rect.fromLTRB(40.0, 85.0, 100.0, 90.0),
          Rect.fromLTRB(0.0, 90.0, 50.0, 95.0),
          Rect.fromLTRB(90.0, 90.0, 100.0, 95.0),
          Rect.fromLTRB(0.0, 95.0, 100.0, 100.0),
        ],
      );
    });
  });
}
