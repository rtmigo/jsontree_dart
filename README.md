![Generic badge](https://img.shields.io/badge/dart-2.17+-blue.svg)
![Generic badge](https://img.shields.io/badge/platform-VM_|_JS-blue.svg)
[![Pub Package](https://img.shields.io/pub/v/jsontree.svg)](https://pub.dev/packages/jsontree)
[![pub points](https://badges.bar/jsontree/pub%20points)](https://pub.dev/packages/jsontree/score)

# [jsontree](https://github.com/rtmigo/jsontree_dart)

Statically typed JSON tree.

The tree can contain JSON-compatible atomic types and nothing else. That is,
only `String`, `int`, `double`, `bool` or `null` -- combined by nested `Map` or
`List` objects.

This allows you to prevent data errors at a very early stage. You will see
warnings from IDE and the program will not compile.

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

Imagine that we need to create some JSON `request`, that will be later converted
to JSON and sent to sever.

#### BAD: dynamic typing

```dart
import 'dart:convert';

main() {
  final request = <String, dynamic>{};  // to be converted to JSON

  // DateTime is not convertible, but we don't know that yet
  request["time"] = DateTime.now();  // oops  
  request["message"] = "Hi!";

  // runtime exception: DateTime cannot be converted
  send(json.convert(request));
}
```

#### GOOD: static typing

``` dart
import 'dart:convert';
import 'package:jsontree/jsontree.dart';

respond() {
  final request = MutableJsonMap();  // no dynamic types

  // to place an object inside MutableJsonMap we are forced to convert each 
  // parameter to a JsonNode. But there's no way to convert DateTime to it,
  // so we have to do it right
  request["time"] = DateTime.now().millisecondsSinceEpoch.jsonNode;  
  request["message"] = "Hi!".jsonNode;

  // no errors, as it should be
  send(json.convert(request));
}
```

## JsonNode tree creation

```x.jsonNode``` creates an object that wraps the `x` value. The type of the
object depends on the type of `x`.

For example, `5.jsonNode` creates `JsonInt(5)`. And `5.23.jsonNode`
creates `JsonDouble(5.23)`.

This works for collections as well.

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

## JsonNode tree to JSON string

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

## JSON string to JsonNode tree

Parsing JSON with this library only makes sense if you want to use the parsed
values to create another tree.

``` dart
final a = JsonNode.fromJsonCode(src1);
final b = JsonNode.fromJsonCode(src2);

print([a, b, "something else".jsonNode].jsonNode.toJsonCode())
```



## JsonNode tree to original objects

You can also call `.toJson()` to get rid of all the wrappers and get the
original set of Dart objects. Because these objects were validated when the tree
was created, the result is guaranteed to be able to be converted to JSON.

``` dart
import 'package:jsontree/jsontree.dart';
import 'dart:convert'
...

JsonList tree = [1.jsonNode, 2.jsonNode].jsonNode;
List<int> list = tree.unwrap();  // [1, 2]

// of course, the list convertible to JSON 
print(json.convert(dartList));
```

## Objects to JsonNode tree

Such conversion is contrary to the purpose of the library. It requires dynamic type checking and can lead to runtime errors.

But if you already have data structures ready, this might be a reasonable compromise.

```dart
final leonard = {
    'name': 'Leonard',
    'surname': 'Hofstadter',
    'iq': 173,
};

JsonNode tree = JsonNode.wrap(tree);
```




## JsonNodes immutability

By default, all objects are immutable.

```dart
JsonMap m = {"a": 1.jsonNode, "b": 2.jsonNode}.jsonNode;
// you can read m or m.data, but cannot change 
```

There are also mutable versions for lists and maps.

```dart
var m = MutableJsonMap({"a": 1.jsonNode, "b": 2.jsonNode});
// you can read/write m and m.data 
```

Mutability and immutability are achievable after the creation of objects.

``` dart
JsonMap readOnly = {"a": 1.jsonNode, "b": 2.jsonNode}.jsonNode;

MutableJsonMap readWrite = readOnly.toMutable();  // creates a copy
readWrite["c"] = 3.jsonNode;

JsonMap readOnlyAgain = readWrite.asImmutable();  // wraps the data as immutable
```

`toMutable` will create a copy of the data, respecting the immutability of
the original objects.

`asImmutable` will just wrap the data into into an object, that does not allow
modification.


## Hierarchy

```
JsonAny
^^ JsonValue
   ^^ JsonInt
      ^^ JsonInt53   (JavaScript range)
      ^^ JsonInt64   (full int64 range) 
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

## Integer ranges

By default, `int.jsonNode` creates a `JsonInt53` object. It only allows you to
set integer values that will not lose precision in JavaScript.

```dart
final a = 5.jsonNode;  // no problem
final b = 9999999999999999.jsonNode;  // throws ArgumentError
```

This restriction is relevant because JSON is literally JavaScript Object
Notation.

But most languages are able to read larger numbers from JSON. To store the full
range number, use `int.jsonNode64`.


```dart
final c = 9999999999999999.jsonNode64;  // no problem
```

## License

Copyright © 2022 [Artёm IG](https://github.com/rtmigo).
Released under the [MIT License](LICENSE).