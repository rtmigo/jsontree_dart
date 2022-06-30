![Generic badge](https://img.shields.io/badge/status-WIP-red.svg)
![Generic badge](https://img.shields.io/badge/dart-2.17+-blue.svg)
![Generic badge](https://img.shields.io/badge/platform-VM_|_JS-blue.svg)

# [jsontree](https://github.com/rtmigo/jsontree_dart)

A library for creating statically checked JSON trees. No dynamic conversion
errors!

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
  final response = <String, dynamic>{}; // to be converted to JSON

  // DateTime is not convertible, but we don't know that yet
  addToResponse(response, "status", "OK");
  addToResponse(response, "time", DateTime.now()); // oops

  // dynamic error: DateTime cannot be converted
  print(json.convert(response));
}
```

#### Good:

``` dart
// we completely get rid of dynamic types: both response and parameters 
// are descendants of `JsonNode`. That means we can only create JSON-compatible
// tree
void addToResponse(MutableJsonMap response, JsonNode item) {
  response[key] = item;
}

main() {
  final response = MutableJsonMap();

  // we are forced to convert each parameter to a JsonNode. And the correctness 
  // of the parameters is checked even before compilation: the IDE will warn you 
  // about an incorrect parameter
  addToResponse(response, "status", "OK".jsonNode);
  addToResponse(response, "time", DateTime.now().millisecondsSinceEpoch.jsonNode);

  // no errors, as it should be
  print(response.toJsonCode());
}
```

## Tree creation

```x.jsonNode``` creates an object that wraps the `x` value. The type of the
object depends on the type of `x`.

For example, `5.jsonNode` creates `JsonInt(5)`. And `5.23.jsonNode`
creates `JsonDouble(5.23)`.

This also works for lists and maps as long as there are node objects inside. You
can do `[1.jsonNode, 2.jsonNode].jsonNode` to get `JsonList<JsonInt>`. But you
can't just do `[1, 2].jsonNode` -- it won't compile.

Regardless of the type, all the wrapper objects will be inherited from the
base `JsonNode`. If you have created a `JsonNode`, you can be sure that there is
JSON-compatible data inside.

## Convert to JSON

For any `JsonNode` object, you can call the `.toJsonCode()` method to convert it
to JSON string.

``` dart
final tree = [1.jsonNode, 2.jsonNode].jsonNode;
print(tree.toJsonCode());
```

## Convert to original objects tree

You can also call `.toBaseValue()` to get rid of all the wrappers and get the
original set of Dart objects. Because these objects were validated when the tree
was created, the result is guaranteed to be able to be converted to JSON.

``` dart
final tree = [1.jsonNode, 2.jsonNode].jsonNode;
final original = tree.toBaseValue();  // [1, 2]
print(json.convert(original));
```

## Immutability

By default, all objects are immutable.

```dart

final JsonMap m = {"a": 1.jsonNode, "b": 2.jsonNode}.jsonNode;
// you can read m or m.data, but cannot change 
```

There are also mutable versions for lists and maps.

```dart

final m = MutableJsonMap({"a": 1.jsonNode, "b": 2.jsonNode});
// you can read/write m and m.data 
```

Mutability and immutability are achievable after the creation of objects.

```dart
final readOnly = {"a": 1.jsonNode, "b": 2.jsonNode}.jsonNode;

final readWrite = readOnly.asMutable();
mutable["c"] = 3.jsonNode;

final readOnlyAgain = readWrite.asImmutable();
```

## Parse JSON

Parsing JSON with this library only makes sense if you want to use the parsed
values to create another tree.

``` dart
final a = JsonNode.fromJsonCode(src1);
final b = JsonNode.fromJsonCode(src2);

print([a, b, "something else".jsonNode].jsonNode.toJsonCode())
```

## Hierarchy

```
JsonAny
^^ JsonValue
   ^^ JsonInt
      ^^ SafeJsonInt     (-9007199254740991 <= x <= 9007199254740991)
      ^^ UnsafeJsonInt   (full int64 range, but inaccurate) 
   ^^ JsonDouble
   ^^ JsonString
^^ JsonList
   ^^ MutableJsonList
^^ JsonMap
   ^^ MutableJsonMap
^^ JsonNull
```

By default, all the objects are immutable except `MutableJsonMap`
and `MutableJsonList`.

All data is statically checked for compatibility, except for `SafeJsonInt`
values.

With an inappropriate value, `SafeJsonInt` will throw an exception at the time
of creation. This is still better than getting an error when converting the
entire tree.

## License

```text
MIT License

Copyright (c) 2022 Artёm IG <github.com/rtmigo>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```