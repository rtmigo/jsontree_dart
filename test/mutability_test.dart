// SPDX-FileCopyrightText: (c) 2022 Artёm IG <github.com/rtmigo>
// SPDX-License-Identifier: MIT

import 'package:jsontree/jsontree.dart';
import 'package:test/test.dart';

void main() {
  group('list', () {
    final tree = [1.jsonNode, 2.jsonNode, 3.jsonNode].jsonNode;

    test('can iterate as standard collection', () {
      expect(tree.data.map((e) => e.unwrap()), [1, 2, 3]);
    });

    test('but cannot modify', () {
      final x = 4.jsonNode;
      expect(() => tree.data.add(x), throwsA(isA<UnsupportedError>()));
    });

    test('can create mutable copy', () {
      final mutable = tree.toMutable();
      final x = 4.jsonNode;
      mutable.data.add(x);

      // value is added to the new object, but not the original
      expect(tree.data.map((e) => e.unwrap()).length, 3);
      expect(mutable.data.map((e) => e.unwrap()).length, 4);
    });

    test('mutable.immutable is immutable', () {
      final x = 4.jsonNode;
      expect(() => tree.toMutable().asImmutable().data.add(x),
          throwsA(isA<UnsupportedError>()));
    });
  });

  group('map', () {
    final tree =
        {"one": 1.jsonNode, "two": 2.jsonNode, "three": 3.jsonNode}.jsonNode;

    test('can iterate as standard collection', () {
      expect(tree.data.values.map((e) => e.unwrap()), [1, 2, 3]);
    });

    test('but cannot modify', () {
      final x = 4.jsonNode;
      expect(() => tree.data["four"] = x, throwsA(isA<UnsupportedError>()));
    });

    test('can create mutable copy', () {
      final mutable = tree.toMutable();
      final x = 4.jsonNode;
      mutable.data["four"] = x;

      // value is added to the new object, but not the original
      expect(tree.data.values.map((e) => e.unwrap()).length, 3);
      expect(mutable.data.values.map((e) => e.unwrap()).length, 4);
    });

    test('mutable.immutable is immutable', () {
      final x = 4.jsonNode;
      expect(() => tree.toMutable().asImmutable().data["four"] = x,
          throwsA(isA<UnsupportedError>()));
    });
  });
}
