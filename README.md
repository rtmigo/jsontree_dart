![Generic badge](https://img.shields.io/badge/status-WIP-red.svg)
![Generic badge](https://img.shields.io/badge/dart-2.17+-blue.svg)
![Generic badge](https://img.shields.io/badge/platform-VM_|_JS-blue.svg)

# [jsontree](https://github.com/rtmigo/jsontree_dart)

A library for creating statically checked JSON trees. No dynamic conversion errors!

## Example

```dart
import 'package:jsontree/jsontree.dart';

void main() {
  final tree = {
    "name": "Joe".jsonNode,
    "age": 30.jsonNode,
    "kids": ["Mary".jsonNode, "Michael".jsonNode].jsonNode
  }.jsonNode;

  print(tree.toJsonCode());
  // {"name":"Joe","age":30,"kids":["Mary","Michael"]}
}
```

## Motivation

Imagine that we are creating a web service. We generate a `response` as a `Map`
and later convert this `Map` to JSON.

#### Bad:

```dart
void addToResponse(Map<String, dynamic> response, String key, dynamic item) {
  response[key] = item; 
}

main() {
  final response = <String, dynamic>{};  // to be converted to JSON

  // DateTime is not convertible, but we don't know that yet
  addToResponse(response, "status", "OK");  
  addToResponse(response, "time", DateTime.now());  // oops

  // dynamic error: DateTime cannot be converted
  print(json.convert(response));  
}
```

#### Good:

```dart
// we completely get rid of dynamic types: both response and parameters 
// are descendants of `JsonNode`. That means we can only create JSON-compatible
// tree
void addToResponse(JsonMap response, JsonNode item) {
  response[key] = item;
}

main() {
  final response = JsonMap();

  // we are forced to convert each parameter to a JsonNode. And the correctness 
  // of the parameters is checked even before compilation: the IDE will warn you 
  // about an incorrect parameter
  addToResponse(response, "status", "OK".jsonNode);
  addToResponse(response, "time", DateTime.now().millisecondsSinceEpoch.jsonNode);

  // no errors, as it should be
  print(response.toJsonCode());
}
```

## Hierarchy

```
JsonAny
^^ JsonValue
   ^^ JsonInt
      ^^ JsonSafeInt     (-9007199254740991 <= x <= 9007199254740991)
      ^^ JsonUnsafeInt   (full int64 range, but inaccurate) 
   ^^ JsonDouble
   ^^ JsonString
^^ JsonList
^^ JsonMap
^^ JsonNull
```
  
