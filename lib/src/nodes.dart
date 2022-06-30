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
  dynamic toBaseValue();

  String toJsonCode() {
    return convert.json.encode(this.toBaseValue());
  }

  static JsonNode fromJsonCode(String json) {
    return fromBaseValue(convert.json.decode(json));
  }

  static JsonNode fromBaseValue(dynamic data, {bool safeIntegers = true}) {
    if (data == null) {
      return JsonNull();
    } else if (data is int) {
      return safeIntegers ? SafeJsonInt(data) : UnsafeJsonInt(data);
    } else if (data is double) {
      return JsonDouble(data);
    } else if (data is String) {
      return JsonString(data);
    } else if (data is bool) {
      return JsonBool(data);
    } else if (data is List) {
      return JsonList(data
          .map((e) => fromBaseValue(e, safeIntegers: safeIntegers))
          .toList());
    } else if (data is Map) {
      return JsonMap(Map<String, JsonNode>.fromEntries(data.entries.map((e) =>
          MapEntry(e.key as String,
              fromBaseValue(e.value, safeIntegers: safeIntegers)))));
    } else {
      throw JsonTypeError("Cannot convert ${data.runtimeType} to JsonItem");
    }
  }
}

class JsonNull extends JsonNode {
  @override
  dynamic toBaseValue() => null;
}

abstract class JsonValue<T> extends JsonNode {
  final T value;

  JsonValue(this.value);
}

abstract class JsonInt extends JsonValue<int> {
  JsonInt(super.value);

  @override
  int toBaseValue() => this.value;
}

class SafeJsonInt extends JsonInt {
  static const int MIN_SAFE_INTEGER = -9007199254740991;
  static const int MAX_SAFE_INTEGER = 9007199254740991;

  SafeJsonInt(super.value) {
    _checkValue(super.value);
  }

  static void _checkValue(int x) {
    if (x < MIN_SAFE_INTEGER || x > MAX_SAFE_INTEGER) {
      throw ArgumentError.value(x,
          "The value cannot be interpreted exactly as a Number in JavaScript.");
    }
  }

  @override
  int toBaseValue() => this.value;
}

class UnsafeJsonInt extends JsonInt {
  UnsafeJsonInt(super.value);

  @override
  int toBaseValue() => this.value;
}

class JsonBool extends JsonValue<bool> {
  JsonBool(super.value);

  @override
  bool toBaseValue() => this.value;
}

class JsonString extends JsonValue<String> {
  JsonString(super.value);

  @override
  String toBaseValue() => this.value;
}

class JsonDouble extends JsonValue<double> {
  JsonDouble(super.value);

  @override
  double toBaseValue() => this.value;
}

class JsonList<T extends JsonNode> extends JsonNode {
  final List<T> _mutable;

  /// Creates an object from an existing list of `JsonNode` elements.
  ///
  /// If immutability is important to you, the original list should not be
  /// modified after the constructor has been called.
  JsonList(this._mutable);

  /// The contents of JsonList, as a standard immutable collection.
  List<T> get data => _immutable ??= List<T>.from(_mutable);
  List<T>? _immutable; // TODO unit test

  int get length => _mutable.length;

  T operator [](int index) => _mutable[index];

  @override
  List<dynamic> toBaseValue() =>
      this._mutable.map((e) => e.toBaseValue()).toList();

  MutableJsonList<T> asMutable() => MutableJsonList(this._mutable);
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
  Map<String, T>? _immutable; // TODO unit test

  int get length => _mutable.length;

  T? operator [](String key) => _mutable[key];

  @override
  Map<String, dynamic> toBaseValue() => Map<String, dynamic>.fromEntries(this
      ._mutable
      .entries
      .map((me) => MapEntry<String, dynamic>(me.key, me.value.toBaseValue())));

  MutableJsonMap<T> asMutable() => MutableJsonMap(this._mutable);
}

class MutableJsonMap<T extends JsonNode> extends JsonMap<T> {
  MutableJsonMap(super.data);

  void operator []=(String key, T value) => _mutable[key] = value;

  /// The contents of `JsonMap`, as a standard mutable collection.
  @override
  Map<String, T> get data => this._mutable;
}

class MutableJsonList<T extends JsonNode> extends JsonList<T> {
  MutableJsonList(super.data);

  void operator []=(int index, T value) => _mutable[index] = value;

  /// The contents of `JsonList`, as a standard mutable collection.
  @override
  List<T> get data => this._mutable;
}
