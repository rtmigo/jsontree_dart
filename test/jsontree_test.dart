// SPDX-FileCopyrightText: (c) 2022 Artёm IG <github.com/rtmigo>
// SPDX-License-Identifier: MIT

import 'dart:convert';

import 'package:jsontree/jsontree.dart';
import 'package:test/test.dart';

class ClassWithToJson {
  final int a;
  final int b;

  ClassWithToJson(this.a, this.b);

  dynamic toJson() => {'a': this.a, 'b': this.b};
}

void main() {
  final data = JsonMap({
    'Fives': JsonList([JsonInt53(5), JsonDouble(5.01), JsonString('Five')]),
    'None': JsonNull(),
    'Inner': {"happy": true.jsonNode, "sad": false.jsonNode}.jsonNode
  });

  void expectEqualToData(base) {
    expect(base['None'], null);
    expect(base['Fives']![0], 5);
    expect(base['Fives']![1], 5.01);
    expect(base['Fives']![2], 'Five');
    expect(base['Inner']!["happy"]!, true);
  }

  const dataAsJsonCode =
      '{"Fives":[5,5.01,"Five"],"None":null,"Inner":{"happy":true,"sad":false}}';

  test('unwrap', () {
    final base = data.unwrap();
    expectEqualToData(base);
  });

  test('wrap/unwrap/wrap', () {
    final base = JsonNode.wrap(data.unwrap()).unwrap();
    expectEqualToData(base);
  });

  test('wrap JsonNode', () {
    final jsonNode = {'a': 1.jsonNode, 'b': 2.jsonNode}.jsonNode;
    final d = JsonNode.wrap(jsonNode).unwrap();
    expect(d['b']!, 2);
  });

  test('wrap any object with toJson method', () {
    final source = {
      'first': ClassWithToJson(1, 2),
      'second': ClassWithToJson(3, 4)
    };
    final restored = JsonNode.wrap(source).unwrap();
    expect(restored['first']!['b']!, 2);
  });

  test('wrapping wrong object throws JsonTypeError', () {
    expect(()=>JsonNode.wrap(DateTime.now()), throwsA(isA<JsonTypeError>()));
  });

  test('.toJson used by convert.json encoder', () {
    expect(json.encode(data), dataAsJsonCode);
  });

  test('encode', () async {
    //print(data.toJsonCode());
    expect(json.encode(data.unwrap()), dataAsJsonCode);
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

  test('JsonDynamic', () async {
    final d = {
      "id": 123.jsonNode,
      "dynamic": JsonDynamic({"a": 1, "b": 2})
    }.jsonNode;

    final data = d.unwrap();

    expect(data["id"]!, 123);
    expect(data["dynamic"]!["a"]!, 1);
    expect(data["dynamic"]!["b"]!, 2);
  });
}
