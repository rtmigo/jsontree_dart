// SPDX-FileCopyrightText: (c) 2022 Artёm IG <github.com/rtmigo>
// SPDX-License-Identifier: MIT

import 'dart:convert' as convert;

class JsonTypeError extends TypeError {
  final String message;

  JsonTypeError(this.message);

  @override
  String toString() {
    return "${this.runtimeType}: ${this.message}";
  }
}

abstract class JsonNode {
  /// Converts this wrapper object to inner object, that is guaranteed to
  /// be JSON-convertible.
  ///
  /// ```dart
  /// var myTree = JsonList([JsonInt(1), JsonInt(2)]);
  /// List<int> simpleList = myTree.toJson();
  /// ```
  dynamic unwrap();

  /// The same as [unwrap]. This alias makes [JsonNode] compatible with
  /// the [json.encode] function.
  ///
  /// ```dart
  /// final myTree = JsonMap(...);
  /// json.encode(myTree);
  /// ```
  dynamic toJson() => unwrap();

  String toJsonCode() {
    return convert.json.encode(this.unwrap());
  }

  static JsonNode fromJsonCode(String json) {
    return wrap(convert.json.decode(json));
  }

  /// Wraps [obj] and all of its children in a tree of [JsonNode] objects.
  ///
  /// ```dart
  /// var map = {'a': 1, 'b': [2.3, 4.5]};
  /// var tree = JsonNode.wrap(map);
  /// ```
  ///
  /// This should only be done if you already have a generated JSON-compatible
  /// object tree.
  static JsonNode wrap(dynamic obj, {bool safeIntegers = true}) {
    if (obj == null) {
      return JsonNull();
    } else if (obj is int) {
      return safeIntegers ? JsonInt53(obj) : JsonInt64(obj);
    } else if (obj is double) {
      return JsonDouble(obj);
    } else if (obj is String) {
      return JsonString(obj);
    } else if (obj is bool) {
      return JsonBool(obj);
    } else if (obj is List) {
      return JsonList(
          obj.map((e) => wrap(e, safeIntegers: safeIntegers)).toList());
    } else if (obj is Map) {
      return JsonMap(Map<String, JsonNode>.fromEntries(obj.entries.map((e) =>
          MapEntry(
              e.key as String, wrap(e.value, safeIntegers: safeIntegers)))));
    } else if (obj is JsonNode) {
      return obj;
    } else {
      dynamic pure;
      try {
        pure = obj.toJson();
      } on NoSuchMethodError {
        throw JsonTypeError("Cannot convert ${obj.runtimeType} to JsonNode");
      }

      return wrap(pure, safeIntegers: safeIntegers);
    }
  }
}

/// Special node, the purpose of which is contrary to the purpose of the
/// library.
///
/// This node can contain any value that we believe is JSON-compliant. The value
/// is of a dynamic type, and it's not checked - it's just stored in the object.
///
/// Such a node is useful if we have guaranteed JSON-compatible data and for
/// performance reasons we don't want to check data types.
///
///
/// ```dart
/// Map<String, dynamic> myHugeSubtree = jsonDecode(dataFromFile);
///
/// final myCheckedTree = {
///   "id": 123.jsonNode,
///   "subtree": JsonDynamic(myHugeSubtree)
/// }.jsonNode;
///
/// ```
class JsonDynamic<T> extends JsonNode {
  final T value;

  JsonDynamic(this.value);

  @override
  dynamic unwrap() => value;
}

class JsonNull extends JsonNode {
  @override
  dynamic unwrap() => null;

  // This is a singleton object.
  factory JsonNull() => _instance;

  JsonNull._();

  static final JsonNull _instance = JsonNull._();
}

abstract class JsonValue<T> extends JsonNode {
  final T value;

  JsonValue(this.value);
}

abstract class JsonInt extends JsonValue<int> {
  JsonInt(super.value);

  @override
  int unwrap() => this.value;
}

class JsonInt53 extends JsonInt {
  static const int minJsInteger = -9007199254740991;
  static const int maxJsInteger = 9007199254740991;

  JsonInt53(super.value) {
    _checkValue(super.value);
  }

  static bool isSafe(int x) => minJsInteger <= x && x <= maxJsInteger;

  static void _checkValue(int x) {
    if (!isSafe(x)) {
      throw ArgumentError.value(
          x,
          "The value is out of range of exact integers in JavaScript. "
          "Use $JsonInt64 if you don't care.");
    }
  }

  @override
  int unwrap() => this.value;
}

class JsonInt64 extends JsonInt {
  JsonInt64(super.value);

  @override
  int unwrap() => this.value;
}

class JsonBool extends JsonValue<bool> {
  JsonBool(super.value);

  @override
  bool unwrap() => this.value;
}

class JsonString extends JsonValue<String> {
  JsonString(super.value);

  @override
  String unwrap() => this.value;
}

class JsonDouble extends JsonValue<double> {
  JsonDouble(super.value);

  @override
  double unwrap() => this.value;
}

class JsonList<T extends JsonNode> extends JsonNode {
  final List<T> _mutable;

  /// Creates an object from an existing list of `JsonNode` elements.
  ///
  /// If immutability is important to you, the original list should not be
  /// modified after the constructor has been called.
  JsonList(this._mutable);

  /// The contents of JsonList, as a standard immutable collection.
  List<T> get data => _immutable ??= List<T>.unmodifiable(_mutable);
  List<T>? _immutable;

  int get length => _mutable.length;

  T operator [](int index) => _mutable[index];

  @override
  List<dynamic> unwrap() => this._mutable.map((e) => e.unwrap()).toList();

  /// Creates a copy.
  MutableJsonList<T> toMutable() =>
      MutableJsonList(List<T>.from(this._mutable));
}

class JsonMap<T extends JsonNode> extends JsonNode {
  final Map<String, T> _mutable;

  /// Creates an object from an existing map of `JsonNode` elements.
  ///
  /// If immutability is important to you, the original map should not be
  /// modified after the constructor has been called.
  JsonMap(this._mutable);

  /// The contents of JsonMap, as a standard immutable collection.
  Map<String, T> get data =>
      _immutable ??= Map<String, T>.unmodifiable(_mutable);
  Map<String, T>? _immutable;

  int get length => _mutable.length;

  T? operator [](String key) => _mutable[key];

  @override
  Map<String, dynamic> unwrap() => Map<String, dynamic>.fromEntries(this
      ._mutable
      .entries
      .map((me) => MapEntry<String, dynamic>(me.key, me.value.unwrap())));

  MutableJsonMap<T> toMutable() =>
      MutableJsonMap(Map<String, T>.from(this._mutable));
}

class MutableJsonMap<T extends JsonNode> extends JsonMap<T> {
  MutableJsonMap(super.data);

  static MutableJsonMap empty<T extends JsonNode>() => MutableJsonMap<T>({});

  void operator []=(String key, T value) => _mutable[key] = value;

  /// The contents of `JsonMap`, as a standard mutable collection.
  @override
  Map<String, T> get data => this._mutable;

  JsonMap<T> asImmutable() => JsonMap(this._mutable);
}

class MutableJsonList<T extends JsonNode> extends JsonList<T> {
  MutableJsonList(super.data);

  static MutableJsonList empty<T extends JsonNode>() => MutableJsonList<T>([]);

  void operator []=(int index, T value) => _mutable[index] = value;

  /// The contents of `JsonList`, as a standard mutable collection.
  @override
  List<T> get data => this._mutable;

  JsonList<T> asImmutable() => JsonList(this._mutable);
}
