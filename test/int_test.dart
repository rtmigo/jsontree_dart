// SPDX-FileCopyrightText: (c) 2022 Artёm IG <github.com/rtmigo>
// SPDX-License-Identifier: MIT

import 'package:jsontree/jsontree.dart';
import 'package:test/test.dart';

void main() {
  test('test constructor', () async {
    expect(JsonInt53(23).value, 23);
    expect(JsonInt53(JsonInt53.maxJsInteger).value, JsonInt53.maxJsInteger);
    expect(JsonInt53(JsonInt53.minJsInteger).value, JsonInt53.minJsInteger);
    expect(() => JsonInt53(JsonInt53.maxJsInteger + 1), throwsArgumentError);
    expect(() => JsonInt53(JsonInt53.minJsInteger - 1), throwsArgumentError);
  });

  test('unsafe', () async {
    expect(JsonInt64(12).toJsonCode(), '12');
    // результаты конвертирования будут отличаться в VM и JS, но только в
    // младших разрядах числа. Мы не тестируем, отличаются ли они - а лишь
    // убеждаемся, что конвертирование таки происходит без исключений
    expect(
        JsonInt64(JsonInt53.maxJsInteger + 10)
            .toJsonCode()
            .startsWith('90071992'),
        true);
  });
}
