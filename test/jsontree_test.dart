// SPDX-FileCopyrightText: (c) 2022 Artёm IG <github.com/rtmigo>
// SPDX-License-Identifier: MIT

import 'dart:convert';

import 'package:jsontree/jsontree.dart';
import 'package:test/test.dart';

void main() {
  final data = JsonMap({
    'Fives': JsonList([JsonInt53(5), JsonDouble(5.01), JsonString('Five')]),
    'None': JsonNull(),
    'Inner': {"happy": true.jsonNode, "sad": false.jsonNode}.jsonNode
  });

  const dataAsJsonCode =
      '{"Fives":[5,5.01,"Five"],"None":null,"Inner":{"happy":true,"sad":false}}';

  test('.toJson (objects)', () {
    final base = data.toJson();
    expect(base['None'], null);
    expect(base['Fives']![0], 5);
    expect(base['Fives']![1], 5.01);
    expect(base['Fives']![2], 'Five');
    expect(base['Inner']!["happy"]!, true);
  });

  test('.toJson used by convert.json encoder', () {
    expect(json.encode(data), dataAsJsonCode);
  });

  test('encode', () async {
    //print(data.toJsonCode());
    expect(json.encode(data.toJson()), dataAsJsonCode);
    expect(data.toJsonCode(), dataAsJsonCode);
  });

  test('decode', () {
    final encoded = data.toJsonCode();
    final decoded = JsonNode.fromJsonCode(encoded);

    final root = decoded as JsonMap;
    final fives = root['Fives']! as JsonList;
    final dbl = fives[1] as JsonDouble;
    expect(dbl.value, 5.01);
  });
}
