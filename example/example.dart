import 'package:jsontree/jsontree.dart';

void main() {
  final tree = {
    "name": "Joe".jsonNode,
    "age": 30.jsonNode,
    "kids": ["Mary".jsonNode, "Michael".jsonNode].jsonNode
  }.jsonNode;

  print(tree.toJsonCode());
  // {"name":"Joe","age":30,"kids":["Mary","Michael"]}

  print(tree.toBaseValue());
  // {name: Joe, age: 30, kids: [Mary, Michael]}
}