// SPDX-FileCopyrightText: (c) 2022 Artёm IG <github.com/rtmigo>
// SPDX-License-Identifier: MIT

import 'nodes.dart';

extension JsonStringExtension on String {
  JsonString get jsonNode => JsonString(this);
}

extension JsonIntExtension on int {
  JsonInt get jsonNode => SafeJsonInt(this);
  JsonInt get jsonUnsafeNode => UnsafeJsonInt(this);
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