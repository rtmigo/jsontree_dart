import 'dart:convert';

import 'package:jsontree/jsontree.dart';
import 'package:test/test.dart';

void main() {
  test('test constructor', () async {
    expect(SafeJsonInt(23).value, 23);
    expect(SafeJsonInt(SafeJsonInt.MAX_SAFE_INTEGER).value, SafeJsonInt.MAX_SAFE_INTEGER);
    expect(SafeJsonInt(SafeJsonInt.MIN_SAFE_INTEGER).value, SafeJsonInt.MIN_SAFE_INTEGER);
    expect(()=>SafeJsonInt(SafeJsonInt.MAX_SAFE_INTEGER+1), throwsArgumentError);
    expect(()=>SafeJsonInt(SafeJsonInt.MIN_SAFE_INTEGER-1), throwsArgumentError);
  });
}
