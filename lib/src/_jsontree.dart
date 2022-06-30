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

  static JsonNode fromBaseTypes(dynamic data) {
    if (data == null) {
      return JsonNull();
    } else if (data is int) {
      return JsonInt(data);
    } else if (data is double) {
      return JsonDouble(data);
    } else if (data is String) {
      return JsonString(data);
    } else if (data is List) {
      return JsonList(data.map(fromBaseTypes).toList());
    } else if (data is Map) {
      return JsonMap(Map<String, JsonNode>.fromEntries(data.entries
          .map((e) => MapEntry(e.key as String, fromBaseTypes(e.value)))));
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

class JsonInt extends JsonValue<int> {
  JsonInt(super.value);

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
  final List<T> _items;

  JsonList(this._items);

  int get length => _items.length;

  T operator [](int index) => _items[index];

  void operator []=(int index, T value) => _items[index] = value;

  @override
  List<dynamic> toBaseValue() =>
      this._items.map((e) => e.toBaseValue()).toList();
}

class JsonMap<T extends JsonNode> extends JsonNode {
  final Map<String, T> _items;

  JsonMap(this._items);

  int get length => _items.length;

  bool containsKey(String key) => this._items.containsKey(key);

  T? operator [](String key) => _items[key];

  void operator []=(String key, T value) => _items[key] = value;

  @override
  Map<String, dynamic> toBaseValue() => Map<String, dynamic>.fromEntries(this
      ._items
      .entries
      .map((me) => MapEntry<String, dynamic>(me.key, me.value.toBaseValue())));
}

extension JsonStringExtension on String {
  JsonString get jsonNode => JsonString(this);
}

extension JsonIntExtension on int {
  JsonInt get jsonNode => JsonInt(this);
}

extension JsonDoubleExtension on double {
  JsonDouble get jsonNode => JsonDouble(this);
}

extension JsonBoolExtension on bool {
  JsonBool get jsonNode => JsonBool(this);
}

extension JsonMapExtension on Map<String, JsonNode> {
  JsonMap get jsonNode => JsonMap(this);
}

extension JsonListExtension on List<JsonNode> {
  JsonList get jsonNode => JsonList(this);
}
