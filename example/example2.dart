import 'package:jsontree/jsontree.dart';

void main() {
  final satellites = MutableJsonList.empty();
  satellites.data.add("Phobos".jsonNode);
  satellites.data.add(JsonString("Deimos"));

  final tree = MutableJsonMap.empty();
  tree.data["planet"] = "Mars".jsonNode;
  tree.data["diameter"] = 6779.jsonNode;
  tree.data["satellites"] = satellites;

  print(tree.toJsonCode());
  // {"planet":"Mars","diameter":6779,"satellites":["Phobos","Deimos"]}
}