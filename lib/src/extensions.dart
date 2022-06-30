import 'nodes.dart';

extension JsonStringExtension on String {
  JsonString get jsonNode => JsonString(this);
}

extension JsonIntExtension on int {
  JsonInt get jsonNode => JsonSafeInt(this);
  JsonInt get jsonUnsafeNode => JsonUnsafeInt(this);
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