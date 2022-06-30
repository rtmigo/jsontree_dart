# [jsontree](https://github.com/rtmigo/jsontree_dart)

(draft) A library for creating JSON trees without surprises.

## Example

```dart
final tree = {
  "name": "Joe".jsonNode,
  "age": 30.jsonNode,
  "kids": ["Mary".jsonNode, "Michael".jsonNode]
}.jsonNode;

print(tree.toBaseValue);
print(tree.toJsonCode());
```

## Motivation

Imagine that we are creating a web service. We generate a `response` as a `Map`
and later convert this `Map` to JSON.

#### Bad:

```dart
void addToResponse(Map<String, dynamic> jsonResponse, String key, dynamic item) {
  jsonResponse["item"] = item; 
}

main() {
  final response = Map<String, dynamic>();

  addToResponse(jsonResponse, "status", "OK");

  // DateTime is not convertible, but we don't know that yet 
  addToResponse(jsonResponse, "time", DateTime.now());

  // oops! Dynamic error: DateTime cannot be converted
  print(json.convert(jsonResponse));  
}
```

#### Better:

```dart
// declaring the param as JsonNode, that is restricted to be some of the 
// JSON-compatible types  
void addToResponse(Map<String, dynamic> jsonResponse, String key, JsonNode param) {
  response["item"] = item.toBaseValue();
}

main() {
  final response = Map<String, dynamic>();
  
  // passing all parameters as JsonNode descendants, 
  // otherwise the compiler will not allow it
  addToResponse(response, "status", "OK".jsonNode);
  addToResponse(response, "time", DateTime.now().millisecondsSinceEpoch.jsonNode);
  
  // works ok
  print(json.convert(response));  
}
```

#### Good:

```dart
// we completely get rid of dynamic types: both response and parameters 
// are descendants of `JsonNode`. That means we can only create JSON-compatible
// tree
void serializeToJson(JsonMap response, JsonNode param) {
  response["item"] = item;
}
```

## Hierarchy

```
JsonAny
^^^^ JsonValue
^^^^^^^^ JsonInt
^^^^^^^^ JsonDouble
^^^^^^^^ JsonString
^^^^^^^^ JsonList
^^^^ JsonMap
^^^^ JsonNull
```
  
