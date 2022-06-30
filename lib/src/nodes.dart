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
    return fromBaseTypes(convert.json.decode(json));
  }

  static JsonNode fromBaseTypes(dynamic data, {bool safeIntegers = true}) {
    if (data == null) {
      return JsonNull();
    } else if (data is int) {
      return safeIntegers ? JsonSafeInt(data) : JsonUnsafeInt(data);
    } else if (data is double) {
      return JsonDouble(data);
    } else if (data is String) {
      return JsonString(data);
    } else if (data is List) {
      return JsonList(data
          .map((e) => fromBaseTypes(e, safeIntegers: safeIntegers))
          .toList());
    } else if (data is Map) {
      return JsonMap(Map<String, JsonNode>.fromEntries(data.entries.map((e) =>
          MapEntry(e.key as String,
              fromBaseTypes(e.value, safeIntegers: safeIntegers)))));
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

class JsonSafeInt extends JsonInt {
  static const int MIN_SAFE_INTEGER = -9007199254740991;
  static const int MAX_SAFE_INTEGER = 9007199254740991;

  JsonSafeInt(super.value) {
    if (this.value < MIN_SAFE_INTEGER || this.value > MAX_SAFE_INTEGER) {
      throw ArgumentError.value(value,
          "The value cannot be interpreted exactly as a Number in JavaScript.");
    }
  }

  @override
  int toBaseValue() => this.value;
}

class JsonUnsafeInt extends JsonInt {
  JsonUnsafeInt(super.value);

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
  /// It can be safely used for reading and writing as a standard collection.
  final List<T> data;

  JsonList(this.data);

  int get length => data.length;

  T operator [](int index) => data[index];

  void operator []=(int index, T value) => data[index] = value;

  @override
  List<dynamic> toBaseValue() => this.data.map((e) => e.toBaseValue()).toList();
}

class JsonMap<T extends JsonNode> extends JsonNode {
  /// It can be safely used for reading and writing as a standard collection.
  final Map<String, T> data;

  JsonMap(this.data);

  int get length => data.length;

  T? operator [](String key) => data[key];

  void operator []=(String key, T value) => data[key] = value;

  @override
  Map<String, dynamic> toBaseValue() => Map<String, dynamic>.fromEntries(this
      .data
      .entries
      .map((me) => MapEntry<String, dynamic>(me.key, me.value.toBaseValue())));
}
