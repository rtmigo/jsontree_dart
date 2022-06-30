import 'dart:convert';

import 'package:jsontree/jsontree.dart';
import 'package:test/test.dart';

void main() {
  test('test constructor', () async {
    expect(JsonSafeInt(23).value, 23);
    expect(JsonSafeInt(JsonSafeInt.MAX_SAFE_INTEGER).value, JsonSafeInt.MAX_SAFE_INTEGER);
    expect(JsonSafeInt(JsonSafeInt.MIN_SAFE_INTEGER).value, JsonSafeInt.MIN_SAFE_INTEGER);
    expect(()=>JsonSafeInt(JsonSafeInt.MAX_SAFE_INTEGER+1), throwsArgumentError);
    expect(()=>JsonSafeInt(JsonSafeInt.MIN_SAFE_INTEGER-1), throwsArgumentError);
  });

  test('test assignment', () async {
    final jsi = JsonSafeInt(23);
    expect(jsi.value, 23);
    jsi.value = 5;
    expect(jsi.value, 5);

    expect(()=>jsi.value = JsonSafeInt.MAX_SAFE_INTEGER+1, throwsArgumentError);
    expect(()=>jsi.value = JsonSafeInt.MIN_SAFE_INTEGER-1, throwsArgumentError);
  });

}
