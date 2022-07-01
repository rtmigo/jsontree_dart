![Generic badge](https://img.shields.io/badge/status-WIP-red.svg)
![Generic badge](https://img.shields.io/badge/dart-2.17+-blue.svg)
![Generic badge](https://img.shields.io/badge/platform-VM_|_JS-blue.svg)

# [jsontree](https://github.com/rtmigo/jsontree_dart)

Statically typed JSON tree.

The tree can contain JSON-compatible atomic types and nothing else. That is,
only `String`, `int`, `double`, `bool` or `null` -- combined by nested `Map` or
`List` objects.

This allows you to prevent data errors at a very early stage. Adding
incompatible data to the tree is not possible: you will see an error in the IDE
and the program will not compile.

## Example

Create a tree in declarative style:

```dart
import 'package:jsontree/jsontree.dart';

void main() {
  final tree = {
    "planet": "Mars".jsonNode,
    "diameter": 6779.jsonNode,
    "satellites": ["Phobos".jsonNode, "Deimos".jsonNode].jsonNode
  }.jsonNode;

  print(tree.toJsonCode());
  // {"planet":"Mars","diameter":6779,"satellites":["Phobos","Deimos"]}
}
```

Or create the tree in an imperative style:

```dart
import 'package:jsontree/jsontree.dart';

void main() {
  final satellites = MutableJsonList.empty();
  satellites.data.add("Phobos".jsonNode);
  satellites.data.add("Deimos".jsonNode);

  final tree = MutableJsonMap.empty();
  tree.data["planet"] = "Mars".jsonNode;
  tree.data["diameter"] = 6779.jsonNode;
  tree.data["satellites"] = satellites;

  print(tree.toJsonCode());
  // {"planet":"Mars","diameter":6779,"satellites":["Phobos","Deimos"]}
}
```

## Motivation

Imagine that we are creating a web service. We generate a `response` as a `Map`
and later convert it to JSON.

#### Bad (dynamic typing):

```dart
import 'dart:convert';

respond() {
  final response = <String, dynamic>{};  // to be converted to JSON

  // DateTime is not convertible, but we don't know that yet
  response["time"] = DateTime.now();  // oops  
  response["status"] = "OK";

  // dynamic error: DateTime cannot be converted
  send(json.convert(response));
}
```

#### Good (static typing):

``` dart
import 'package:jsontree/jsontree.dart';

respond() {
  final response = MutableJsonMap();  // no dynamic types

  // to place an object inside MutableJsonMap we are forced to convert each 
  // parameter to a JsonNode. But there's no way to convert DateTime to it,
  // so we have to do it right
  response["time"] = DateTime.now().millisecondsSinceEpoch.jsonNode;  
  response["status"] = "OK".jsonNode;

  // no errors, as it should be
  send(response.toJsonCode());
}
```

## Tree creation

```x.jsonNode``` creates an object that wraps the `x` value. The type of the
object depends on the type of `x`.

For example, `5.jsonNode` creates `JsonInt(5)`. And `5.23.jsonNode`
creates `JsonDouble(5.23)`.

This works for structures as well.

``` dart
final sheldon = {
    'name': 'Sheldon'.jsonNode,
    'surname': 'Cooper'.jsonNode,
    'iq': 187.jsonNode,
    'girlfriends': 1.jsonNode
}.jsonNode; 

// you can't add .jsonNode to the map if you miss at least 
// one .jsonNode added to elements

final leonard = {
    'name': 'Leonard'.jsonNode,
    'surname': 'Hofstadter'.jsonNode,
    'iq': 173.jsonNode,
    'girlfriends': 4.jsonNode
}.jsonNode;

// connect these nodes into an even larger structure

final tree = {
    'science': 'physics'.jsonNode,
    'neighbours': [leonard, sheldon].jsonNode
}.jsonNode; 
```

Regardless of the type, all the wrapper objects will be inherited from the
base `JsonNode`. If you have created a `JsonNode`, you can be sure that there is
JSON-compatible data inside.

## Tree to JSON string

For any `JsonNode` object, you can call the `.toJsonCode()` method to convert it
to JSON string.

``` dart
import 'package:jsontree/jsontree.dart';
...

final tree = [1.jsonNode, 2.jsonNode].jsonNode;
print(tree.toJsonCode());
```

You can also pass the tree directly to `json.convert`:

``` dart
import 'package:jsontree/jsontree.dart';
import 'dart:convert';
...

final tree = [1.jsonNode, 2.jsonNode].jsonNode;
print(json.convert(tree));
```


## Tree to original objects

You can also call `.toJson()` to get rid of all the wrappers and get the
original set of Dart objects. Because these objects were validated when the tree
was created, the result is guaranteed to be able to be converted to JSON.

``` dart
import 'package:jsontree/jsontree.dart';
import 'dart:convert'
...

final tree = [1.jsonNode, 2.jsonNode].jsonNode;
final original = tree.toJson();  // [1, 2]
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

``` dart
final readOnly = {"a": 1.jsonNode, "b": 2.jsonNode}.jsonNode;

final readWrite = readOnly.toMutable();  // creates a copy
mutable["c"] = 3.jsonNode;

final readOnlyAgain = readWrite.asImmutable();  // wraps the data as immutable
```

`toMutable` will create a copy of the data, respecting the immutability of
the original objects.

`asImmutable` will just wrap the data into into an object, that does not allow
modification.

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
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

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