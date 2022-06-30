import 'dart:convert';

import 'package:jsontree/jsontree.dart';
import 'package:test/test.dart';

void main() {
  test('test safe', () async {
    expect(JsonSafeInt(23).value, 23);
    expect(JsonSafeInt(JsonSafeInt.MAX_SAFE_INTEGER).value, JsonSafeInt.MAX_SAFE_INTEGER);
    expect(JsonSafeInt(JsonSafeInt.MIN_SAFE_INTEGER).value, JsonSafeInt.MIN_SAFE_INTEGER);
    expect(()=>JsonSafeInt(JsonSafeInt.MAX_SAFE_INTEGER+1), throwsArgumentError);
    expect(()=>JsonSafeInt(JsonSafeInt.MIN_SAFE_INTEGER-1), throwsArgumentError);
  });

}
