import 'dart:convert';

import 'package:jsontree/jsontree.dart';
import 'package:test/test.dart';

void main() {
  final data = JsonMap({
    'Fives': JsonList([JsonInt(5), JsonDouble(5.01), JsonString('Five')]),
    'None': JsonNull()
  });

  test('toBaseType', () async {
    final base = data.toBaseValue();
    expect(base['None'], null);
    expect(base['Fives']![0], 5);
    expect(base['Fives']![1], 5.01);
    expect(base['Fives']![2], 'Five');
  });

  test('encode', () async {
    const expected = '{"Fives":[5,5.01,"Five"],"None":null}';
    expect(json.encode(data.toBaseValue()), expected);
    expect(data.toJsonCode(), expected);
  });

  test('decode', () async {
    final encoded = data.toJsonCode();
    final decoded = JsonNode.fromJsonCode(encoded);

    final root = decoded as JsonMap;
    final fives = root['Fives']! as JsonList;
    final dbl = fives[1] as JsonDouble;
    expect(dbl.value, 5.01);
  });
}
