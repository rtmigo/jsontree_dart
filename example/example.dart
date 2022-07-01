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